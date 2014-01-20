from smoke.protobuf import dota2_palm as pbd2
from smoke.io import factory as io_fctr
from smoke.io import plexer as io_plxr
from smoke.replay import handler as rply_hndlr
from smoke.replay import match as rply_mtch
from smoke.replay import ticker as rply_tckr
from smoke.util import enum


def mk(demo_io, **kwargs):
    return Demo(demo_io, **kwargs)


Game = enum(Entities     = 1 << 0, TempEntities = 1 << 1, Modifiers = 1 << 2,
            UserMessages = 1 << 3, GameEvents   = 1 << 4, Sounds    = 1 << 5,
            VoiceData    = 1 << 6, All          = 0xFF)


PB_DEPENDENCIES = {
    'Entities': [pbd2.svc_UpdateStringTable, pbd2.svc_PacketEntities],
    'TempEntities': [pbd2.svc_TempEntities],
    'Modifiers': [pbd2.svc_UpdateStringTable],
    'UserMessages': [pbd2.svc_UserMessage],
    'GameEvents': [pbd2.svc_GameEvent],
    'Sounds': [pbd2.svc_Sounds],
    'VoiceData': [pbd2.svc_VoiceData]
}


EMBED_WHITELIST = set([pbd2.net_Tick, pbd2.net_SetConVar, pbd2.svc_SendTable,
    pbd2.net_SignonState, pbd2.svc_ServerInfo, pbd2.svc_ClassInfo,
    pbd2.svc_CreateStringTable, pbd2.svc_SetView, pbd2.svc_VoiceInit,
    pbd2.svc_GameEventList])


class Demo(object):
    @classmethod
    def calc_deps(self, parse):
        deps = set()
        coll = Game.tuples.copy()

        del coll['All']

        for key, value in coll.items():
            if (parse & value):
                deps.update(PB_DEPENDENCIES[key])

        return deps | EMBED_WHITELIST

    @classmethod
    def mk_embed_blacklist(self, deps):
        embed_blacklist = set()

        for embed in io_fctr.EMBED.keys():
            if embed not in deps:
                embed_blacklist.add(embed)

        return embed_blacklist

    def __init__(self, d_io, parse=Game.All, skip_full=True, match=None):
        tb = set([pbd2.DEM_FullPacket]) if skip_full else set()
        eb = Demo.mk_embed_blacklist(Demo.calc_deps(parse))

        self.parse = parse
        self.plexer = io_plxr.mk(d_io, top_blacklist=tb, embed_blacklist=eb)
        self.match = match or rply_mtch.mk()

    def bootstrap(self):
        while True:
            try:
                _, pb = self.plexer.read()
                rply_hndlr.handle(pb, self.match)
            except io_plxr.DEMSyncTickEncountered:
                break

    def play(self):
        return rply_tckr.mk(self.plexer, self.match)

    def finish(self):
        while True:
            try:
                _, pb = self.plexer.read()
                rply_hndlr.handle(pb, self.match)
            except EOFError:
                break
