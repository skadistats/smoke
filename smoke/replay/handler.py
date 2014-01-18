from collections import OrderedDict
from protobuf.impl import demo_pb2 as pb_d
from protobuf.impl import netmessages_pb2 as pb_n
from protobuf.impl import networkbasetypes_pb2 as pb_nbt
from smoke.io.stream import entity as io_strm_ntt
from smoke.model.collection import entities as mdl_cllctn_ntts
from smoke.model.collection import game_event_descriptors as \
    mdl_cllctn_gmvntdscrptrs
from smoke.model.collection.game_event_descriptors import GameEventDescriptor
from smoke.model.collection import string_tables as mdl_cllctn_strngtbl
from smoke.model.dt.prop import Prop, Type
from smoke.model.dt.send_table import SendTable
from smoke.model.string_table import String
from smoke.replay.decoder import string_table as rply_dcdr_strngtbl


def handle(pb, match):
    HANDLERS[type(pb)](pb, match)


def handle_dem_fileheader(pb, match):
    file_header = {
        'demo_file_stamp': pb.demo_file_stamp,
        'network_protocol': pb.network_protocol,
        'server_name': pb.server_name,
        'client_name': pb.client_name,
        'map_name': pb.map_name,
        'game_directory': pb.game_directory,
        'fullpackets_version': pb.fullpackets_version,
        'allow_clientside_entities': pb.allow_clientside_entities,
        'allow_clientside_particles': pb.allow_clientside_particles
    }

    match.file_header = file_header


def handle_svc_serverinfo(pb, match):
    server_info = {
        'server_count': pb.server_count,
        'is_dedicated': pb.is_dedicated,
        'is_hltv': pb.is_hltv,
        'is_replay': pb.is_replay,
        'c_os': pb.c_os,
        'map_crc': pb.map_crc,
        'client_crc': pb.client_crc,
        'string_table_crc': pb.string_table_crc,
        'max_clients': pb.max_clients,
        'max_classes': pb.max_classes,
        'player_slot': pb.player_slot,
        'tick_interval': pb.tick_interval,
        'game_dir': pb.game_dir,
        'map_name': pb.map_name,
        'sky_name': pb.sky_name,
        'host_name': pb.host_name
    }

    match.server_info = server_info


def handle_net_tick(pb, match):
    match.tick = pb.tick
    match.reset_transient_state()


def handle_net_setconvar(pb, match):
    con_vars = match.con_vars or dict()

    for cvar in pb.convars.cvars:
        name, value = cvar.name, cvar.value
        con_vars[name] = value

    match.con_vars = con_vars


def handle_svc_createstringtable(pb, match):
    basis_string_tables = match.basis_string_tables or \
        mdl_cllctn_strngtbl.mk()

    string_table = rply_dcdr_strngtbl.decode_and_create(pb)

    index = len(basis_string_tables.by_index)
    basis_string_tables.mapping[index] = string_table
    basis_string_tables.by_name[pb.name] = string_table

    match.basis_string_tables = basis_string_tables


def handle_net_signonstate(pb, match):
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


def handle_svc_sendtable(pb, match):
    send_tables = match.send_tables or dict()

    send_props = []

    for sp in pb.props:
        # for send props of type Type.Array, the previous property stored is
        # the "template" for each of the items in the array.
        array_prop = send_props[-1] if sp.type is Type.Array else None

        send_prop = Prop(
            pb.net_table_name,
            sp.var_name, sp.type, sp.flags, sp.priority, sp.num_elements,
            sp.num_bits, sp.dt_name, sp.low_value, sp.high_value,
            array_prop
        )

        send_props.append(send_prop)

    send_tables[pb.net_table_name] = \
        SendTable(pb.net_table_name, send_props, pb.needs_decoder)

    match.send_tables = send_tables


def handle_dem_classinfo(pb, match):
    match.class_info = {i.table_name:int(i.class_id) for i in pb.classes}


def handle_svc_voiceinit(pb, match):
    voice_init = {
        'quality': pb.quality,
        'codec': pb.codec,
        'version': pb.version
    }

    match.voice_init = voice_init


def handle_svc_gameeventlist(pb, match):
    game_event_descriptors = mdl_cllctn_gmvntdscrptrs.mk()

    for desc in pb.descriptors:
        eventid, name = desc.eventid, desc.name
        keys = [(k.type, k.name) for k in desc.keys]
        game_event_descriptor = GameEventDescriptor(eventid, name, keys)
        game_event_descriptors.by_eventid[eventid] = game_event_descriptor
        game_event_descriptors.by_name[name] = game_event_descriptor

    match.game_event_descriptors = game_event_descriptors


def handle_svc_setview(pb, match):
    match.view = { 'entity_index': pb.entity_index }


def handle_svc_packetentities(pb, match):
    match.entities = match.entities or mdl_cllctn_ntts.mk()

    s = io_strm_ntt.mk(pb.entity_data)
    d, n = pb.is_delta, pb.updated_entries
    patch = match.packet_entities_decoder.decode(s, d, n, match.entities)

    match.entities.apply(patch)


def handle_svc_gameevent(pb, match):
    pass


def handle_svc_usermessage(pb, match):
    pass


def handle_svc_updatestringtable(pb, match):
    pass


def handle_svc_tempentities(pb, match):
    pass


def handle_svc_sounds(pb, match):
    pass


def handle_svc_voicedata(pb, match):
    pass


def handle_dem_fileinfo(pb, match):
    pass


HANDLERS = {
    pb_d.CDemoFileHeader: handle_dem_fileheader,
    pb_n.CSVCMsg_ServerInfo: handle_svc_serverinfo,
    pb_n.CNETMsg_Tick: handle_net_tick,
    pb_n.CNETMsg_SetConVar: handle_net_setconvar,
    pb_n.CSVCMsg_CreateStringTable: handle_svc_createstringtable,
    pb_n.CNETMsg_SignonState: handle_net_signonstate,
    pb_n.CSVCMsg_SendTable: handle_svc_sendtable,
    pb_d.CDemoClassInfo: handle_dem_classinfo,
    pb_n.CSVCMsg_VoiceInit: handle_svc_voiceinit,
    pb_n.CSVCMsg_GameEventList: handle_svc_gameeventlist,
    pb_n.CSVCMsg_SetView: handle_svc_setview,
    pb_n.CSVCMsg_PacketEntities: handle_svc_packetentities,
    pb_nbt.CSVCMsg_GameEvent: handle_svc_gameevent,
    pb_nbt.CSVCMsg_UserMessage: handle_svc_usermessage,
    pb_n.CSVCMsg_UpdateStringTable: handle_svc_updatestringtable,
    pb_n.CSVCMsg_TempEntities: handle_svc_tempentities,
    pb_n.CSVCMsg_Sounds: handle_svc_sounds,
    pb_n.CSVCMsg_VoiceData: handle_svc_voicedata,
    pb_d.CDemoFileInfo: handle_dem_fileinfo
}
