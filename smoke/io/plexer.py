import collections
import warnings

from protobuf.impl import demo_pb2 as pb_d
from protobuf.impl import netmessages_pb2 as pb_n
from smoke.io import factory as io_fctr
from smoke.io.wrap import embed as io_wrp_mbd
from smoke.util import enum


def mk(demo_io, **args):
    return Plexer(demo_io, **args)


class DEMSyncTickEncountered(RuntimeError):
    pass


class DEMStopEncountered(RuntimeError):
    pass


Action = enum(Enqueue = 0, Inline = 1, Ignore = 2)


OPERATIONS = {
    pb_d.DEM_ClassInfo:           Action.Enqueue,
    pb_d.DEM_ConsoleCmd:          Action.Ignore,
    pb_d.DEM_CustomData:          Action.Ignore,
    pb_d.DEM_CustomDataCallbacks: Action.Ignore,
    pb_d.DEM_FileHeader:          Action.Enqueue,
    pb_d.DEM_FileInfo:            Action.Enqueue,
    pb_d.DEM_FullPacket:          Action.Enqueue,
    pb_d.DEM_Packet:              Action.Inline,
    pb_d.DEM_SendTables:          Action.Inline,
    pb_d.DEM_SignonPacket:        Action.Inline,
    pb_d.DEM_StringTables:        Action.Ignore,
    pb_d.DEM_Stop:                Action.Enqueue,
    pb_d.DEM_SyncTick:            Action.Enqueue,
    pb_d.DEM_UserCmd:             Action.Ignore
}


TOP_WHITELIST = set([pb_d.DEM_FileHeader, pb_d.DEM_ClassInfo,
    pb_d.DEM_SignonPacket, pb_d.DEM_SyncTick, pb_d.DEM_Packet, pb_d.DEM_Stop,
    pb_d.DEM_FileInfo])


class Plexer(object):
    def __init__(self, demo_io, top_blacklist=None, embed_blacklist=None):
        tb = top_blacklist or set()
        tb = set(tb) - TOP_WHITELIST

        eb = embed_blacklist or set()
        eb = set(eb) | set([pb_n.svc_ClassInfo])

        self.demo_io = demo_io
        self.queue = collections.deque()
        self.top_blacklist = tb
        self.embed_blacklist = eb
        self.stopped = False

    def read(self):
        peek, pb = self.lookahead()

        self.queue.popleft()

        if peek.kind is pb_d.DEM_SyncTick:
            raise DEMSyncTickEncountered()

        return peek, pb

    def read_tick(self):
        if self.stopped:
            raise DEMStopEncountered()

        tick_peek, tick_pb = self.read()
        assert tick_peek.kind == pb_n.net_Tick, tick_peek.kind
        collection = [(tick_peek, tick_pb)]

        next_peek, next_pb = self.lookahead()
        while next_peek.kind is not pb_n.net_Tick:
            peek, pb = self.read()

            if peek.kind is pb_d.DEM_Stop:
                self.stopped = True
                break

            collection.append((peek, pb))
            next_peek, next_pb = self.lookahead()

        return collection

    def lookahead(self):
        while len(self.queue) == 0:
            peek, message = self.demo_io.read()
            kind = peek.kind

            try:
                op = OPERATIONS[kind]
            except KeyError, e:
                warnings.warn('unhandled top #{}'.format(kind))
                continue

            if op is not Action.Ignore and kind not in self.top_blacklist:
                pb = io_fctr.mk_top(peek, message)

                if op is Action.Enqueue:
                    self.queue.append((peek, pb))
                    continue

                # otherwise, inline embedded messages:
                embed_io = io_wrp_mbd.mk(pb.data, peek.tick)

                for peek, message in embed_io:
                    if peek.kind in self.embed_blacklist:
                        continue

                    try:
                        pb = io_fctr.mk_embed(peek, message)
                        self.queue.append((peek, pb))
                    except KeyError:
                        warnings.warn('unhandled embed #{}'.format(kind))

        return self.queue[0]
