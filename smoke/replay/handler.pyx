# cython: profile=False

import warnings

from smoke.io.stream cimport entity as io_strm_ntt
from smoke.model cimport string_table as mdl_strngtbl
from smoke.model.collection cimport entities as mdl_cllctn_ntts
from smoke.model.collection cimport game_event_descriptors as mdl_cllctn_gmvntdscrptrs
from smoke.model.collection cimport string_tables as mdl_cllctn_strngtbl
from smoke.model.dt cimport send_table as mdl_dt_sndtbl
from smoke.replay cimport match as rply_mtch
from smoke.replay.decoder cimport dt as rply_dcdr_dt
from smoke.replay.decoder cimport packet_entities as rply_dcdr_pcktntts
from smoke.replay.decoder cimport string_table as rply_dcdr_strngtbl
from smoke.replay.decoder cimport temp_entities as rply_dcdr_tmpntts
from smoke.replay.decoder.recv_prop cimport abstract
from smoke.replay.decoder.recv_prop cimport factory

from collections import defaultdict
from smoke.model.const import GameEventDescriptor
from smoke.model.dt.const import Prop, Type
from smoke.model.const import Entity, PVS, String
from smoke.protobuf import dota2_palm as pbd2


DOTA_UM_ID_BASE = 64


cdef object CDemoFileHeader = pbd2.CDemoFileHeader
cdef object CSVCMsg_ServerInfo = pbd2.CSVCMsg_ServerInfo
cdef object CNETMsg_Tick = pbd2.CNETMsg_Tick
cdef object CNETMsg_SetConVar = pbd2.CNETMsg_SetConVar
cdef object CSVCMsg_CreateStringTable = pbd2.CSVCMsg_CreateStringTable
cdef object CNETMsg_SignonState = pbd2.CNETMsg_SignonState
cdef object CSVCMsg_SendTable = pbd2.CSVCMsg_SendTable
cdef object CDemoClassInfo = pbd2.CDemoClassInfo
cdef object CSVCMsg_VoiceInit = pbd2.CSVCMsg_VoiceInit
cdef object CSVCMsg_GameEventList = pbd2.CSVCMsg_GameEventList
cdef object CSVCMsg_SetView = pbd2.CSVCMsg_SetView
cdef object CSVCMsg_PacketEntities = pbd2.CSVCMsg_PacketEntities
cdef object CSVCMsg_GameEvent = pbd2.CSVCMsg_GameEvent
cdef object CSVCMsg_UserMessage = pbd2.CSVCMsg_UserMessage
cdef object CSVCMsg_UpdateStringTable = pbd2.CSVCMsg_UpdateStringTable
cdef object CSVCMsg_TempEntities = pbd2.CSVCMsg_TempEntities
cdef object CSVCMsg_Sounds = pbd2.CSVCMsg_Sounds
cdef object CSVCMsg_VoiceData = pbd2.CSVCMsg_VoiceData
cdef object CDemoFileInfo = pbd2.CDemoFileInfo


cdef object USER_MESSAGE_BY_KIND = {
    1: 'AchievementEvent',          2: 'CloseCaption',
    3: 'CloseCaptionDirect',        4: 'CurrentTimescale',
    5: 'DesiredTimescale',          6: 'Fade',
    7: 'GameTitle',                 8: 'Geiger',
    9: 'HintText',                 10: 'HudMsg',
   11: 'HudText',                  12: 'KeyHintText',
   13: 'MessageText',              14: 'RequestState',
   15: 'ResetHUD',                 16: 'Rumble',
   17: 'SayText',                  18: 'SayText2',
   19: 'SayTextChannel',           20: 'Shake',
   21: 'ShakeDir',                 22: 'StatsCrawlMsg',
   23: 'StatsSkipState',           24: 'TextMsg',
   25: 'Tilt',                     26: 'Train',
   27: 'VGUIMenu',                 28: 'VoiceMask',
   29: 'VoiceSubtitle',            30: 'SendAudio',
   63: 'MAX_BASE',                 64: 'AddUnitToSelection',
   65: 'AIDebugLine',              66: 'ChatEvent',
   67: 'CombatHeroPositions',      68: 'CombatLogData',
   70: 'CombatLogShowDeath',       71: 'CreateLinearProjectile',
   72: 'DestroyLinearProjectile',  73: 'DodgeTrackingProjectiles',
   74: 'GlobalLightColor',         75: 'GlobalLightDirection',
   76: 'InvalidCommand',           77: 'LocationPing',
   78: 'MapLine',                  79: 'MiniKillCamInfo',
   80: 'MinimapDebugPoint',        81: 'MinimapEvent',
   82: 'NevermoreRequiem',         83: 'OverheadEvent',
   84: 'SetNextAutobuyItem',       85: 'SharedCooldown',
   86: 'SpectatorPlayerClick',     87: 'TutorialTipInfo',
   88: 'UnitEvent',                89: 'ParticleManager',
   90: 'BotChat',                  91: 'HudError',
   92: 'ItemPurchased',            93: 'Ping',
   94: 'ItemFound',                95: 'CharacterSpeakConcept',
   96: 'SwapVerify',               97: 'WorldLine',
   98: 'TournamentDrop',           99: 'ItemAlert',
  100: 'HalloweenDrops',          101: 'ChatWheel',
  102: 'ReceivedXmasGift',        103: 'UpdateSharedContent',
  104: 'TutorialRequestExp',      105: 'TutorialPingMinimap',
  106: 'GamerulesStateChanged',   107: 'ShowSurvey',
  108: 'TutorialFade',            109: 'AddQuestLogEntry',
  110: 'SendStatPopup',           111: 'TutorialFinish',
  112: 'SendRoshanPopup',         113: 'SendGenericToolTip',
  114: 'SendFinalGold',           115: 'CustomMsg',
  116: 'CoachHUDPing',            117: 'ClientLoadGridNav'
}


cdef handle(io_pk.Peek peek, rply_mtch.Match match):
    cdef object pb = peek.mk()
    cdef object t = type(pb)

    if t == CDemoFileHeader:
        _handle_dem_fileheader(pb, match)
    elif t == CSVCMsg_ServerInfo:
        _handle_svc_serverinfo(pb, match)
    elif t == CNETMsg_Tick:
        _handle_net_tick(pb, match)
    elif t == CNETMsg_SetConVar:
        _handle_net_setconvar(pb, match)
    elif t == CSVCMsg_CreateStringTable:
        _handle_svc_createstringtable(pb, match)
    elif t == CNETMsg_SignonState:
        _handle_net_signonstate(pb, match)
    elif t == CSVCMsg_SendTable:
        _handle_svc_sendtable(pb, match)
    elif t == CDemoClassInfo:
        _handle_dem_classinfo(pb, match)
    elif t == CSVCMsg_VoiceInit:
        _handle_svc_voiceinit(pb, match)
    elif t == CSVCMsg_GameEventList:
        _handle_svc_gameeventlist(pb, match)
    elif t == CSVCMsg_SetView:
        _handle_svc_setview(pb, match)
    elif t == CSVCMsg_PacketEntities:
        _handle_svc_packetentities(pb, match)
    elif t == CSVCMsg_GameEvent:
        _handle_svc_gameevent(pb, match)
    elif t == CSVCMsg_UserMessage:
        _handle_svc_usermessage(pb, match)
    elif t == CSVCMsg_UpdateStringTable:
        _handle_svc_updatestringtable(pb, match)
    elif t == CSVCMsg_TempEntities:
        _handle_svc_tempentities(pb, match)
    elif t == CSVCMsg_Sounds:
        _handle_svc_sounds(pb, match)
    elif t == CSVCMsg_VoiceData:
        _handle_svc_voicedata(pb, match)
    elif t == CDemoFileInfo:
        _handle_dem_fileinfo(pb, match)
    else:
        raise RuntimeError(t)


cdef void _handle_dem_fileheader(object pb, rply_mtch.Match match):
    file_header = {
        'demo_file_stamp': pb.get('demo_file_stamp'),
        'network_protocol': pb.get('network_protocol'),
        'server_name': pb.get('server_name'),
        'client_name': pb.get('client_name'),
        'map_name': pb.get('map_name'),
        'game_directory': pb.get('game_directory'),
        'fullpackets_version': pb.get('fullpackets_version'),
        'allow_clientside_entities': pb.get('allow_clientside_entities'),
        'allow_clientside_particles': pb.get('allow_clientside_particles')
    }

    match.file_header = file_header


cdef void _handle_svc_serverinfo(object pb, rply_mtch.Match match):
    server_info = {
        'server_count': pb.get('server_count'),
        'is_dedicated': pb.get('is_dedicated'),
        'is_hltv': pb.get('is_hltv'),
        'is_replay': pb.get('is_replay'),
        'c_os': pb.get('c_os'),
        'map_crc': pb.get('map_crc'),
        'client_crc': pb.get('client_crc'),
        'string_table_crc': pb.get('string_table_crc'),
        'max_clients': pb.get('max_clients'),
        'max_classes': pb.get('max_classes'),
        'player_slot': pb.get('player_slot'),
        'tick_interval': pb.get('tick_interval'),
        'game_dir': pb.get('game_dir'),
        'map_name': pb.get('map_name'),
        'sky_name': pb.get('sky_name'),
        'host_name': pb.get('host_name')
    }

    match.server_info = server_info


cdef void _handle_net_tick(object pb, rply_mtch.Match match):
    match.tick = pb.tick
    match.reset_transient_state()


cdef void _handle_net_setconvar(object pb, rply_mtch.Match match):
    con_vars = match.con_vars or dict()

    for cvar in pb.convars.cvars:
        name, value = cvar.name, cvar.value
        con_vars[name] = value

    match.con_vars = con_vars


cdef void _handle_svc_createstringtable(object pb, rply_mtch.Match match):
    match.string_tables = match.string_tables or mdl_cllctn_strngtbl.Collection()

    cdef mdl_strngtbl.StringTable string_table
    cdef string_tables = <mdl_cllctn_strngtbl.Collection>match.string_tables

    index = len(string_tables.by_index)
    string_table = rply_dcdr_strngtbl.decode_and_create(pb)

    string_tables.by_index[index] = string_table
    string_tables.by_name[pb.name] = string_table

    match.string_tables = string_tables


cdef void _handle_net_signonstate(object pb, rply_mtch.Match match):
    cdef rply_dcdr_pcktntts.Decoder ped
    cdef io_strm_ntt.Stream stream

    signon_state = {
        'signon_state': pb.signon_state,
        'spawn_count': pb.spawn_count,
        'num_server_players': pb.num_server_players
    }

    match.signon_state = signon_state

    # 5 indicates complete signon. It's a constant in the Source engine.
    if signon_state['signon_state'] == 5:
        match.flatten_send_tables()
        match.check_sanity()

        ped = <rply_dcdr_pcktntts.Decoder>match.packet_entities_decoder

        # populate instance baselines
        instance_baselines = match.string_tables.by_name['instancebaseline']

        for string in instance_baselines.by_index.values():
            cls = int(string.name)
            stream = io_strm_ntt.Stream(string.value)
            prop_list = stream.read_entity_prop_list()
            match._instance_baseline_cache[cls] = \
                ped.fetch_decoder(cls).decode(stream, prop_list)

        active_modifiers = match.string_tables.by_name['ActiveModifiers']
        modifiers = defaultdict(dict)

        for string in active_modifiers.by_index.values():
            if len(string.value) == 0:
                continue
            _pb = pbd2.CDOTAModifierBuffTableEntry(string.value)
            assert _pb.entry_type == pbd2.DOTA_MODIFIER_ENTRY_TYPE_ACTIVE
            modifiers[_pb.parent][_pb.index] = _pb

        match.modifiers = modifiers


cdef void _handle_svc_sendtable(object pb, rply_mtch.Match match):
    send_tables = match.send_tables or dict()
    send_props = list()

    for sp in pb.props:
        # for send props of type Type.Array, the previous property stored is
        # the "template" for each of the items in the array.
        array_prop = send_props[-1] if sp.type is Type.Array else None

        num_elements = sp.get('num_elements')
        num_bits = sp.get('num_bits')
        dt_name = sp.get('dt_name')
        low_value = sp.get('low_value')
        high_value = sp.get('high_value')

        send_prop = Prop(
            pb.net_table_name,
            sp.var_name, sp.type, sp.flags, sp.priority, num_elements,
            num_bits, dt_name, low_value, high_value, array_prop)

        send_props.append(send_prop)

    needs_decoder = pb.get('needs_decoder')

    try:
        send_tables[pb.net_table_name] = \
            mdl_dt_sndtbl.SendTable(pb.get('net_table_name'), send_props, needs_decoder)
    except Exception, e:
        assert pb.is_end

    match.send_tables = send_tables


cdef void _handle_dem_classinfo(object pb, rply_mtch.Match match):
    match.class_info = {i.table_name:int(i.class_id) for i in pb.classes}


cdef void _handle_svc_voiceinit(object pb, rply_mtch.Match match):
    voice_init = {
        'quality': pb.quality,
        'codec': pb.codec,
        'version': pb.version
    }

    match.voice_init = voice_init


cdef void _handle_svc_gameeventlist(object pb, rply_mtch.Match match):
    cdef mdl_cllctn_gmvntdscrptrs.Collection game_event_descriptors = mdl_cllctn_gmvntdscrptrs.Collection()

    for desc in pb.descriptors:
        eventid, name = desc.eventid, desc.name
        keys = [(k.type, k.name) for k in desc.keys]
        game_event_descriptor = GameEventDescriptor(eventid, name, keys)
        game_event_descriptors.by_eventid[eventid] = game_event_descriptor
        game_event_descriptors.by_name[name] = game_event_descriptor

    match.game_event_descriptors = game_event_descriptors


cdef void _handle_svc_setview(object pb, rply_mtch.Match match):
    match.view = { 'entity_index': pb.entity_index }


cdef void _handle_svc_packetentities(object pb, rply_mtch.Match match):
    match.entities = match.entities or mdl_cllctn_ntts.Collection()

    cdef rply_dcdr_pcktntts.Decoder ped = <rply_dcdr_pcktntts.Decoder>match.packet_entities_decoder
    cdef mdl_cllctn_ntts.Collection e = <mdl_cllctn_ntts.Collection>match.entities
    cdef list patch = ped.decode(pb, match.entities)

    e.apply(patch, match._instance_baseline_cache)


cdef void _handle_svc_gameevent(object pb, rply_mtch.Match match):
    attrs = []
    ged = match.game_event_descriptors.by_eventid[pb.eventid]

    for i, (k_type, k_name) in enumerate(ged.keys):
        key = pb.keys[i]

        if k_type == 1:
            value = key.val_string
        elif k_type == 2:
            value = key.val_float
        elif k_type == 3:
            value = key.val_long
        elif k_type == 4:
            value = key.val_short
        elif k_type == 5:
            value = key.val_byte
        elif k_type == 6:
            value = key.val_bool
        elif k_type == 7:
            value = key.val_uint64

        attrs.append(value)

    match.game_events[pb.eventid].append(attrs)


cdef void _handle_svc_usermessage(object pb, rply_mtch.Match match):
    kind = pb.msg_type

    if kind == 106: # one-off?
        cls = 'CDOTA_UM_GamerulesStateChanged'
    else:
        infix = 'DOTA' if kind >= DOTA_UM_ID_BASE else ''
        cls = 'C{0}UserMsg_{1}'.format(infix, USER_MESSAGE_BY_KIND[kind])

    try:
        pb = getattr(pbd2, cls)(pb.msg_data)
    except AttributeError, e:
        err = '! protobuf {0}: open issue at github.com/onethirtyfive/smoke'
        warnings.warn(err.format(cls))
        return

    match.user_messages[kind].append(pb)


cdef void _handle_svc_updatestringtable(object pb, rply_mtch.Match match):
    cdef rply_dcdr_pcktntts.Decoder ped =<rply_dcdr_pcktntts.Decoder>match.packet_entities_decoder
    cdef mdl_strngtbl.StringTable string_table = <mdl_strngtbl.StringTable>match.string_tables.by_index[pb.table_id]
    cdef io_strm_ntt.Stream stream
    cdef rply_dcdr_dt.Decoder dt_decoder
 
    update = rply_dcdr_strngtbl.decode_update(pb, string_table)

    for string in update:
        string_table.update(string)

    if string_table.name == 'instancebaseline':
        for string in update:
            cls = int(string.name)
            stream = io_strm_ntt.Stream(string.value)
            prop_list = stream.read_entity_prop_list()
            dt_decoder = ped.fetch_decoder(cls)
            match._instance_baseline_cache[cls] = dt_decoder.decode(stream, prop_list)

    if string_table.name == 'ActiveModifiers':
        for string in update:
            _pb = pbd2.CDOTAModifierBuffTableEntry(string.value)

            if _pb.entry_type == pbd2.DOTA_MODIFIER_ENTRY_TYPE_ACTIVE:
                match.modifiers[_pb.parent][_pb.index] = _pb
            else:
                assert _pb.entry_type == pbd2.DOTA_MODIFIER_ENTRY_TYPE_REMOVED

                try:
                    for_parent = match.modifiers[_pb.parent]

                    try:
                        del for_parent[_pb.index]
                    except KeyError:
                        pass

                    if len(for_parent) == 0:
                        del match.modifiers[_pb.parent]
                except KeyError:
                    pass


cdef void _handle_svc_tempentities(object pb, rply_mtch.Match match):
    cdef rply_dcdr_tmpntts.Decoder ted = <rply_dcdr_tmpntts.Decoder>match.temp_entities_decoder

    match.temp_entities = ted.decode(pb)


cdef void _handle_svc_sounds(object pb, rply_mtch.Match match):
    match.sounds = pb


cdef void _handle_svc_voicedata(object pb, rply_mtch.Match match):
    match.voice_data.append(pb)


cdef void _handle_dem_fileinfo(object pb, rply_mtch.Match match):
    game_info = pb.game_info.dota

    players = []
    for player_details in game_info.player_info:
        entry = {
            'hero_name': player_details.get('hero_name'),
            'player_name': player_details.get('player_name'),
            'is_fake_client': player_details.get('is_fake_client'),
            'steam_id': player_details.get('steamid'),
            'game_team': player_details.get('game_team')
        }
        players.append(entry)

    picks_bans = []
    for hero_selection_details in game_info.picks_bans:
        entry = {
            'is_pick': hero_selection_details.get('is_pick'),
            'team': hero_selection_details.get('team'),
            'hero_id': hero_selection_details.get('hero_id')
        }
        picks_bans.append(entry)

    overview = {
        'playback': {
            'time': pb.get('playback_time'),
            'ticks': pb.get('playback_ticks'),
            'frames': pb.get('playback_frames')
        },
        'game': {
            'players': players,
            'hero_selections': picks_bans,
            'match_id': game_info.get('match_id'),
            'game_mode': game_info.get('game_mode'),
            'game_winner': game_info.get('game_winner'),
            'league_id': game_info.get('leagueid'),
            'radiant_team': {
                'id': game_info.get('radiant_team_id'),
                'tag': game_info.get('radiant_team_tag')
            },
            'dire_team': {
                'id': game_info.get('dire_team_id'),
                'tag': game_info.get('dire_team_tag')
            },
            'end_time': game_info.get('end_time')
        }
    }

    match.overview = overview
