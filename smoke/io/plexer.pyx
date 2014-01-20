import collections
import warnings

from smoke.protobuf import dota2_palm as pbd2
from smoke.io.const import Action, DEMSyncTickEncountered, DEMStopEncountered
from smoke.io import factory as io_fctr
from smoke.io.wrap import embed as io_wrp_mbd


cpdef mk(object demo_io, top_blacklist=None, embed_blacklist=None):
    return Plexer(demo_io, top_blacklist=top_blacklist, embed_blacklist=embed_blacklist)


cdef object OPERATIONS = {
    pbd2.DEM_ClassInfo:           Action.Enqueue,
    pbd2.DEM_ConsoleCmd:          Action.Ignore,
    pbd2.DEM_CustomData:          Action.Ignore,
    pbd2.DEM_CustomDataCallbacks: Action.Ignore,
    pbd2.DEM_FileHeader:          Action.Enqueue,
    pbd2.DEM_FileInfo:            Action.Enqueue,
    pbd2.DEM_FullPacket:          Action.Enqueue,
    pbd2.DEM_Packet:              Action.Inline,
    pbd2.DEM_SendTables:          Action.Inline,
    pbd2.DEM_SignonPacket:        Action.Inline,
    pbd2.DEM_StringTables:        Action.Ignore,
    pbd2.DEM_Stop:                Action.Enqueue,
    pbd2.DEM_SyncTick:            Action.Enqueue,
    pbd2.DEM_UserCmd:             Action.Ignore
}


cdef object TOP_WHITELIST = set([pbd2.DEM_FileHeader, pbd2.DEM_ClassInfo,
    pbd2.DEM_SignonPacket, pbd2.DEM_SyncTick, pbd2.DEM_Packet, pbd2.DEM_Stop,
    pbd2.DEM_FileInfo])


cdef class Plexer(object):
    cdef object demo_io
    cdef object queue
    cdef object top_blacklist
    cdef object embed_blacklist
    cdef object stopped

    def __init__(self, demo_io, top_blacklist=None, embed_blacklist=None):
        tb = top_blacklist or set()
        tb = set(tb) - TOP_WHITELIST

        eb = embed_blacklist or set()
        eb = set(eb) | set([pbd2.svc_ClassInfo])

        self.demo_io = demo_io
        self.queue = collections.deque()
        self.top_blacklist = tb
        self.embed_blacklist = eb
        self.stopped = False

    def read(self):
        peek, pb = self.lookahead()

        self.queue.popleft()

        if peek.kind is pbd2.DEM_SyncTick:
            raise DEMSyncTickEncountered()

        return peek, pb

    def read_tick(self):
        if self.stopped:
            raise DEMStopEncountered()

        tick_peek, tick_pb = self.read()
        assert tick_peek.kind == pbd2.net_Tick, tick_peek.kind
        collection = [(tick_peek, tick_pb)]

        next_peek, next_pb = self.lookahead()
        while next_peek.kind is not pbd2.net_Tick:
            peek, pb = self.read()

            if peek.kind is pbd2.DEM_Stop:
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
