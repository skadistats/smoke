# cython: profile=False

import collections
import warnings

from smoke.io cimport peek as io_pk
from smoke.io.wrap cimport embed as io_wrp_mbd

from smoke.protobuf import dota2_palm as io_pk
from smoke.io.const import DEMSyncTickEncountered, DEMStopEncountered


cdef enum Action:
    NONE = 0
    ENQUEUE = 1
    IGNORE = 2
    INLINE = 3


cdef set TOP_WHITELIST = set([io_pk.DEM_FileHeader, io_pk.DEM_ClassInfo,
    io_pk.DEM_SignonPacket, io_pk.DEM_SyncTick, io_pk.DEM_Packet,
    io_pk.DEM_Stop, io_pk.DEM_FileInfo])


cdef class Plexer(object):
    def __init__(self, wrap, top_blacklist=None, embed_blacklist=None):
        cdef set tb, eb

        tb = top_blacklist or set()
        tb = set(tb) - TOP_WHITELIST

        eb = embed_blacklist or set()
        eb = set(eb) | set([io_pk.svc_ClassInfo])

        self.wrap = wrap
        self.queue = collections.deque()
        self.top_blacklist = tb
        self.embed_blacklist = eb
        self.stopped = False

    cdef io_pk.Peek read(self):
        cdef io_pk.Peek peek = self.lookahead()

        self.queue.popleft()

        if peek.kind is io_pk.DEM_SyncTick:
            raise DEMSyncTickEncountered()

        return peek

    cdef list read_tick(self):
        cdef:
            list collection
            io_pk.Peek tick_peek, next_peek, peek

        if self.stopped:
            raise DEMStopEncountered()

        tick_peek = self.read()
        assert tick_peek.kind == io_pk.net_Tick, tick_peek.kind
        collection = [tick_peek]

        next_peek = self.lookahead()
        while next_peek.kind is not io_pk.net_Tick:
            peek = self.read()

            if peek.kind is io_pk.DEM_Stop:
                self.stopped = True
                break

            collection.append(peek)
            next_peek = self.lookahead()

        return collection

    cdef io_pk.Peek lookahead(self):
        cdef:
            io_pk.Peek peek
            str message
            int action = NONE
            io_wrp_mbd.Wrap wrap
            object pb

        while len(self.queue) == 0:

            peek = self.wrap.read()

            if peek.kind == io_pk.DEM_Packet:
                action = INLINE
            elif peek.kind == io_pk.DEM_FullPacket:
                action = ENQUEUE
            elif peek.kind == io_pk.DEM_SignonPacket:
                action = INLINE
            elif peek.kind == io_pk.DEM_ClassInfo:
                action = ENQUEUE
            elif peek.kind == io_pk.DEM_FileHeader:
                action = ENQUEUE
            elif peek.kind == io_pk.DEM_FileInfo:
                action = ENQUEUE
            elif peek.kind == io_pk.DEM_SendTables:
                action = INLINE
            elif peek.kind == io_pk.DEM_ConsoleCmd:
                action = IGNORE
            elif peek.kind == io_pk.DEM_CustomData:
                action = IGNORE
            elif peek.kind == io_pk.DEM_CustomDataCallbacks:
                action = IGNORE
            elif peek.kind == io_pk.DEM_StringTables:
                action = IGNORE
            elif peek.kind == io_pk.DEM_UserCmd:
                action = IGNORE
            elif peek.kind == io_pk.DEM_Stop:
                action = ENQUEUE
            elif peek.kind == io_pk.DEM_SyncTick:
                action = ENQUEUE

            assert action != NONE

            if action is NONE:
                warnings.warn('unhandled top #{}'.format(peek.kind))
                continue

            if action is not IGNORE and peek.kind not in self.top_blacklist:
                pb = peek.mk()

                if action is ENQUEUE:
                    self.queue.append(peek)
                    continue

                # otherwise, inline embedded messages:
                wrap = io_wrp_mbd.Wrap(pb.data, tick=peek.tick)

                try:
                    while True:
                        peek = wrap.read()
                        if peek.kind in self.embed_blacklist:
                            continue

                        try:
                            self.queue.append(peek)
                        except KeyError:
                            warnings.warn('unhandled embed #{}'.format(peek.kind))
                except EOFError:
                    pass

        return self.queue[0]
