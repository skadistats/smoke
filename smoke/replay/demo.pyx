# cython: profile=False

from smoke.io cimport peek as io_pk
from smoke.io cimport plexer as io_plxr
from smoke.replay cimport match as rply_mtch

from smoke.replay import dispatch as rply_dsptch
from smoke.replay import ticker as rply_tckr
from smoke.io import const as io_cnst
from smoke.protobuf import dota2_palm as pbd2
from smoke.replay.const import Data


cdef dict DATA_DEPENDENCIES = {
    Data.Entities: [io_pk.svc_UpdateStringTable, io_pk.svc_PacketEntities],
    Data.TempEntities: [io_pk.svc_TempEntities],
    Data.Modifiers: [io_pk.svc_UpdateStringTable],
    Data.UserMessages: [io_pk.svc_UserMessage],
    Data.GameEvents: [io_pk.svc_GameEvent],
    Data.Sounds: [io_pk.svc_Sounds],
    Data.VoiceData: [io_pk.svc_VoiceData] }


cdef set ALL_EMBEDS = set([
    io_pk.net_Tick, io_pk.net_SetConVar, io_pk.net_SignonState,
    io_pk.svc_ServerInfo, io_pk.svc_SendTable, io_pk.svc_ClassInfo,
    io_pk.svc_CreateStringTable, io_pk.svc_UpdateStringTable,
    io_pk.svc_VoiceInit, io_pk.svc_VoiceData, io_pk.svc_Sounds,
    io_pk.svc_SetView, io_pk.svc_UserMessage, io_pk.svc_EntityMessage,
    io_pk.svc_GameEvent, io_pk.svc_PacketEntities, io_pk.svc_TempEntities,
    io_pk.svc_GameEventList])


cdef set EMBED_WHITELIST = set([io_pk.net_Tick, io_pk.net_SetConVar,
    io_pk.svc_SendTable, io_pk.net_SignonState, io_pk.svc_ServerInfo,
    io_pk.svc_ClassInfo, io_pk.svc_CreateStringTable, io_pk.svc_SetView,
    io_pk.svc_VoiceInit, io_pk.svc_GameEventList])


cdef set calc_deps(int parse):
    cdef set deps = set()

    for key, value in DATA_DEPENDENCIES.items():
        if (parse & key):
            deps.update(value)

    return deps | EMBED_WHITELIST


cdef set mk_embed_blacklist(object deps):
    cdef set embed_blacklist = set()

    for embed in ALL_EMBEDS:
        if embed not in deps:
            embed_blacklist.add(embed)

    return embed_blacklist


cdef class Demo(object):
    def __init__(self, d_io, parse=Data.All, skip_full=True, match=None):
        tb = set([io_pk.DEM_FullPacket]) if skip_full else set()
        eb = mk_embed_blacklist(calc_deps(parse))

        self.parse = parse
        self.plexer = io_plxr.Plexer(d_io, top_blacklist=tb, embed_blacklist=eb)
        self.match = match or rply_mtch.Match()

    cpdef bootstrap(Demo self):
        cdef io_pk.Peek peek

        try:
            while True:
                peek = self.plexer.read()
                rply_dsptch.dispatch(peek, self.match)
        except io_cnst.DEMSyncTickEncountered:
            pass

    cpdef play(Demo self):
        return rply_tckr.Ticker(self.plexer, self.match)

    cpdef finish(Demo self):
        try:
            while True:
                peek = self.plexer.read()
                rply_dsptch.dispatch(peek, self.match)
        except EOFError:
            pass
