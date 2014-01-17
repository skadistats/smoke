from protobuf.impl import netmessages_pb2 as pb_n
from protobuf.impl import demo_pb2 as pb_d
from smoke.io import factory as io_fctr
from smoke.io import plexer as io_plxr
from smoke.replay import handler as rpl_hndlr
from smoke.replay import match as rpl_mtch
from smoke.util import enum


def mk(demo_io, **kwargs):
    return Demo(demo_io, **kwargs)


Game = enum(Entities     = 1 << 0, TempEntities = 1 << 1, Modifiers = 1 << 2,
            UserMessages = 1 << 3, GameEvents   = 1 << 4, Sounds    = 1 << 5,
            VoiceData    = 1 << 6, All          = 0xFF)


PB_DEPENDENCIES = {
    'Entities': [pb_n.svc_UpdateStringTable, pb_n.svc_PacketEntities],
    'TempEntities': [pb_n.svc_TempEntities],
    'Modifiers': [pb_n.svc_UpdateStringTable],
    'UserMessages': [pb_n.svc_UserMessage],
    'GameEvents': [pb_n.svc_GameEvent],
    'Sounds': [pb_n.svc_Sounds],
    'VoiceData': [pb_n.svc_VoiceData]
}


EMBED_WHITELIST = set([pb_n.net_Tick, pb_n.net_SetConVar, pb_n.svc_SendTable,
    pb_n.net_SignonState, pb_n.svc_ServerInfo, pb_n.svc_ClassInfo,
    pb_n.svc_CreateStringTable, pb_n.svc_SetView, pb_n.svc_VoiceInit,
    pb_n.svc_GameEventList])


class Ticker(object):
    def __init__(self, plexer, match):
        self.plexer = plexer
        self.match = match

    def __iter__(self):
        collection = self.plexer.read_tick()

        for _, pb in collection:
            rpl_hndlr.handle(pb, self.match)

        yield self.match


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
        tb = set([pb_d.DEM_FullPacket]) if skip_full else set()
        eb = Demo.mk_embed_blacklist(Demo.calc_deps(parse))

        self.parse = parse
        self.plexer = io_plxr.mk(d_io, top_blacklist=tb, embed_blacklist=eb)
        self.match = match or rpl_mtch.mk()

    def bootstrap(self):
        while True:
            try:
                _, pb = self.plexer.read()
                rpl_hndlr.handle(pb, self.match)
            except io_plxr.DEMSyncTickEncountered:
                break

    def stream(self):
        while True:
            try:
                for _, pb in self.plexer.read_tick():
                    rpl_hndlr.handle(pb, self.match)
            except io_plxr.DEMStopEncountered:
                break

    def finish(self):
        while True:
            try:
                _, pb = self.plexer.read()
                rpl_hndlr.handle(pb, self.match)
            except EOFError:
                break
