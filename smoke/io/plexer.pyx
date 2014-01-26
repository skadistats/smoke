# cython: profile=False

import collections
import warnings

from smoke.io cimport factory
from smoke.io.wrap cimport embed as io_wrp_mbd

from smoke.protobuf import dota2_palm as pbd2
from smoke.io.const import Action, DEMSyncTickEncountered, DEMStopEncountered


cdef int Enqueue = Action.Enqueue
cdef int Ignore = Action.Ignore
cdef int Inline = Action.Inline


cdef dict OPERATIONS = {
    pbd2.DEM_ClassInfo:           Enqueue,
    pbd2.DEM_ConsoleCmd:          Ignore,
    pbd2.DEM_CustomData:          Ignore,
    pbd2.DEM_CustomDataCallbacks: Ignore,
    pbd2.DEM_FileHeader:          Enqueue,
    pbd2.DEM_FileInfo:            Enqueue,
    pbd2.DEM_FullPacket:          Enqueue,
    pbd2.DEM_Packet:              Inline,
    pbd2.DEM_SendTables:          Inline,
    pbd2.DEM_SignonPacket:        Inline,
    pbd2.DEM_StringTables:        Ignore,
    pbd2.DEM_Stop:                Enqueue,
    pbd2.DEM_SyncTick:            Enqueue,
    pbd2.DEM_UserCmd:             Ignore
}


cdef set TOP_WHITELIST = set([pbd2.DEM_FileHeader, pbd2.DEM_ClassInfo,
    pbd2.DEM_SignonPacket, pbd2.DEM_SyncTick, pbd2.DEM_Packet, pbd2.DEM_Stop])


cdef class Plexer(object):
    def __init__(self, wrap, top_blacklist=None, embed_blacklist=None):
        cdef set tb, eb

        tb = top_blacklist or set()
        tb = set(tb) - TOP_WHITELIST

        eb = embed_blacklist or set()
        eb = set(eb) | set([pbd2.svc_ClassInfo])

        self.wrap = wrap
        self.queue = collections.deque()
        self.top_blacklist = tb
        self.embed_blacklist = eb
        self.stopped = False

    cdef tuple read(self):
        peek, pb = self.lookahead()

        self.queue.popleft()

        if peek.kind is pbd2.DEM_SyncTick:
            raise DEMSyncTickEncountered()

        return peek, pb

    cdef list read_tick(self):
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

    cdef object lookahead(self):
        cdef object peek
        cdef str message
        cdef int op, kind
        cdef io_wrp_mbd.Wrap wrap
        cdef object pb

        while len(self.queue) == 0:
            peek, message = self.wrap.read()
            kind = peek.kind

            try:
                op = OPERATIONS[kind]
            except KeyError, e:
                warnings.warn('unhandled top #{}'.format(kind))
                continue

            if op is not Action.Ignore and kind not in self.top_blacklist:
                pb = factory.mk_top(peek, message)

                if op is Action.Enqueue:
                    self.queue.append((peek, pb))
                    continue

                # otherwise, inline embedded messages:
                wrap = io_wrp_mbd.Wrap(pb.data, peek.tick)

                try:
                    while True:
                        peek, message = wrap.read()

                        if peek.kind in self.embed_blacklist:
                            continue

                        try:
                            pb = factory.mk_embed(peek, message)
                            self.queue.append((peek, pb))
                        except KeyError:
                            warnings.warn('unhandled embed #{}'.format(kind))
                except EOFError:
                    pass

        return self.queue[0]
