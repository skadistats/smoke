from smoke.protobuf import dota2_palm as pbd2
from smoke.io import factory as io_fctr
from smoke.io import plexer as io_plxr
from smoke.replay import handler as rply_hndlr
from smoke.replay import match as rply_mtch
from smoke.replay import ticker as rply_tckr
from smoke.replay.const import Game


cpdef mk(demo_io, parse=Game.All, skip_full=True, match=None):
    return Demo(demo_io, parse=parse, skip_full=skip_full, match=match)


cdef object PB_DEPENDENCIES = {
    'Entities': [pbd2.svc_UpdateStringTable, pbd2.svc_PacketEntities],
    'TempEntities': [pbd2.svc_TempEntities],
    'Modifiers': [pbd2.svc_UpdateStringTable],
    'UserMessages': [pbd2.svc_UserMessage],
    'GameEvents': [pbd2.svc_GameEvent],
    'Sounds': [pbd2.svc_Sounds],
    'VoiceData': [pbd2.svc_VoiceData],
    'Overview': [pbd2.DEM_FileInfo]
}


cdef object EMBED_WHITELIST = set([pbd2.net_Tick, pbd2.net_SetConVar,
    pbd2.svc_SendTable, pbd2.net_SignonState, pbd2.svc_ServerInfo,
    pbd2.svc_ClassInfo, pbd2.svc_CreateStringTable, pbd2.svc_SetView,
    pbd2.svc_VoiceInit, pbd2.svc_GameEventList])


cpdef calc_deps(int parse):
    cdef object deps = set()
    cdef object coll = Game.tuples.copy()

    del coll['All']

    for key, value in coll.items():
        if (parse & value):
            deps.update(PB_DEPENDENCIES[key])

    return deps | EMBED_WHITELIST


cpdef mk_embed_blacklist(object deps):
    cdef object embed_blacklist = set()

    for embed in io_fctr.EMBED.keys():
        if embed not in deps:
            embed_blacklist.add(embed)

    return embed_blacklist


cdef class Demo(object):
    cdef public int parse
    cdef public object plexer
    cdef public object match
    cdef public object overview

    def __init__(self, d_io, parse=Game.All, skip_full=True, match=None):
        tb = set([pbd2.DEM_FullPacket]) if skip_full else set()
        eb = mk_embed_blacklist(calc_deps(parse))

        self.parse = parse
        self.plexer = io_plxr.mk(d_io, top_blacklist=tb, embed_blacklist=eb)
        self.match = match or rply_mtch.mk()

    cpdef bootstrap(Demo self):
        try:
            while True:
                _, pb = self.plexer.read()
                rply_hndlr.handle(pb, self.match)
        except io_plxr.DEMSyncTickEncountered:
            pass

    cpdef play(Demo self):
        return rply_tckr.mk(self.plexer, self.match)

    cpdef finish(Demo self):
        try:
            while True:
                _, pb = self.plexer.read()
                rply_hndlr.handle(pb, self.match)
        except EOFError:
            pass
