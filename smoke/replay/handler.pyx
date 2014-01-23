import warnings

from collections import defaultdict
from smoke.protobuf import dota2_palm as pbd2
from smoke.io.stream import entity as io_strm_ntt
from smoke.model.collection import entities as mdl_cllctn_ntts
from smoke.model.collection import game_event_descriptors as \
    mdl_cllctn_gmvntdscrptrs
from smoke.model.collection.game_event_descriptors import GameEventDescriptor
from smoke.model.collection import string_tables as mdl_cllctn_strngtbl
from smoke.model.dt.const import Prop, Type
from smoke.model.dt.send_table import SendTable
from smoke.model.const import Entity, PVS, String
from smoke.replay.decoder import string_table as rply_dcdr_strngtbl


DOTA_UM_ID_BASE = 64


USER_MESSAGE_BY_KIND = {
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


cpdef handle(pb, match):
    HANDLERS[type(pb)](pb, match)


cpdef handle_dem_fileheader(pb, match):
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


cpdef handle_svc_serverinfo(pb, match):
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


cpdef handle_net_tick(pb, match):
    match.tick = pb.tick
    match.reset_transient_state()


cpdef handle_net_setconvar(pb, match):
    con_vars = match.con_vars or dict()

    for cvar in pb.convars.cvars:
        name, value = cvar.name, cvar.value
        con_vars[name] = value

    match.con_vars = con_vars


cpdef handle_svc_createstringtable(pb, match):
    string_tables = match.string_tables or mdl_cllctn_strngtbl.mk()
    index = len(string_tables.by_index)
    string_table = rply_dcdr_strngtbl.decode_and_create(pb)

    string_tables.by_index[index] = string_table
    string_tables.by_name[pb.name] = string_table

    match.string_tables = string_tables


cpdef handle_net_signonstate(pb, match):
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

        # populate instance baselines
        instance_baselines = match.string_tables.by_name['instancebaseline']

        for string in instance_baselines.by_index.values():
            cls = int(string.name)
            ntt_stream = io_strm_ntt.mk(string.value)
            prop_list = ntt_stream.read_entity_prop_list()
            match._instance_baseline_cache[cls] = \
                match.packet_entities_decoder[cls].decode(ntt_stream, prop_list)

        active_modifiers = match.string_tables.by_name['ActiveModifiers']
        modifiers = defaultdict(dict)

        for string in active_modifiers.by_index.values():
            if len(string.value) == 0:
                continue
            _pb = pbd2.CDOTAModifierBuffTableEntry(string.value)
            assert _pb.entry_type == pbd2.DOTA_MODIFIER_ENTRY_TYPE_ACTIVE
            modifiers[_pb.parent][_pb.index] = _pb

        match.modifiers = modifiers


cpdef handle_svc_sendtable(pb, match):
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
            SendTable(pb.get('net_table_name'), send_props, needs_decoder)
    except:
        assert pb.is_end

    match.send_tables = send_tables


cpdef handle_dem_classinfo(pb, match):
    match.class_info = {i.table_name:int(i.class_id) for i in pb.classes}


cpdef handle_svc_voiceinit(pb, match):
    voice_init = {
        'quality': pb.quality,
        'codec': pb.codec,
        'version': pb.version
    }

    match.voice_init = voice_init


cpdef handle_svc_gameeventlist(pb, match):
    game_event_descriptors = mdl_cllctn_gmvntdscrptrs.mk()

    for desc in pb.descriptors:
        eventid, name = desc.eventid, desc.name
        keys = [(k.type, k.name) for k in desc.keys]
        game_event_descriptor = GameEventDescriptor(eventid, name, keys)
        game_event_descriptors.by_eventid[eventid] = game_event_descriptor
        game_event_descriptors.by_name[name] = game_event_descriptor

    match.game_event_descriptors = game_event_descriptors


cpdef handle_svc_setview(pb, match):
    match.view = { 'entity_index': pb.entity_index }


cpdef handle_svc_packetentities(pb, match):
    match.entities = match.entities or mdl_cllctn_ntts.mk()

    s = io_strm_ntt.mk(pb.entity_data)
    d, n = pb.is_delta, pb.updated_entries
    patch = match.packet_entities_decoder.decode(s, d, n, match.entities)

    match.entities.apply(patch, match._instance_baseline_cache)


cpdef handle_svc_gameevent(pb, match):
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


cpdef handle_svc_usermessage(pb, match):
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


cpdef handle_svc_updatestringtable(pb, match):
    string_table = match.string_tables.by_index[pb.table_id]
    update = rply_dcdr_strngtbl.decode_update(pb, string_table)

    for string in update:
        string_table.update(string)

    if string_table.name == 'instancebaseline':
        for string in update:
            cls = int(string.name)
            ntt_stream = io_strm_ntt.mk(string.value)
            prop_list = ntt_stream.read_entity_prop_list()
            match._instance_baseline_cache[cls] = \
                match.packet_entities_decoder[cls].decode(ntt_stream, prop_list)

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


cpdef handle_svc_tempentities(pb, match):
    match.temp_entities = match.temp_entities or defaultdict(list)

    class_bits = match.packet_entities_decoder.class_bits
    stream = io_strm_ntt.mk(pb.entity_data)
    i = 0

    while i < pb.num_entries:
        mystery = stream.read_numeric_bits(1) # always 0?
        new_cls = stream.read_numeric_bits(1)

        if new_cls:
            cls = stream.read_numeric_bits(class_bits)

        prop_list = stream.read_entity_prop_list()

        state = match.packet_entities_decoder[cls-1].decode(stream, prop_list)
        match.temp_entities[cls].append(Entity(0, 0, PVS.Enter, state))
        i += 1


cpdef handle_svc_sounds(pb, match):
    match.sounds = pb


cpdef handle_svc_voicedata(pb, match):
    match.voice_data.append(pb)


cpdef handle_dem_fileinfo(pb, match):
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


HANDLERS = {
    pbd2.CDemoFileHeader: handle_dem_fileheader,
    pbd2.CSVCMsg_ServerInfo: handle_svc_serverinfo,
    pbd2.CNETMsg_Tick: handle_net_tick,
    pbd2.CNETMsg_SetConVar: handle_net_setconvar,
    pbd2.CSVCMsg_CreateStringTable: handle_svc_createstringtable,
    pbd2.CNETMsg_SignonState: handle_net_signonstate,
    pbd2.CSVCMsg_SendTable: handle_svc_sendtable,
    pbd2.CDemoClassInfo: handle_dem_classinfo,
    pbd2.CSVCMsg_VoiceInit: handle_svc_voiceinit,
    pbd2.CSVCMsg_GameEventList: handle_svc_gameeventlist,
    pbd2.CSVCMsg_SetView: handle_svc_setview,
    pbd2.CSVCMsg_PacketEntities: handle_svc_packetentities,
    pbd2.CSVCMsg_GameEvent: handle_svc_gameevent,
    pbd2.CSVCMsg_UserMessage: handle_svc_usermessage,
    pbd2.CSVCMsg_UpdateStringTable: handle_svc_updatestringtable,
    pbd2.CSVCMsg_TempEntities: handle_svc_tempentities,
    pbd2.CSVCMsg_Sounds: handle_svc_sounds,
    pbd2.CSVCMsg_VoiceData: handle_svc_voicedata,
    pbd2.CDemoFileInfo: handle_dem_fileinfo
}
