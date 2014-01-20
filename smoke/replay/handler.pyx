from collections import OrderedDict
from smoke.protobuf import dota2_palm as pbd2
from smoke.io.stream import entity as io_strm_ntt
from smoke.model.collection import entities as mdl_cllctn_ntts
from smoke.model.collection import game_event_descriptors as \
    mdl_cllctn_gmvntdscrptrs
from smoke.model.collection.game_event_descriptors import GameEventDescriptor
from smoke.model.collection import string_tables as mdl_cllctn_strngtbl
from smoke.model.dt.const import Prop, Type
from smoke.model.dt.send_table import SendTable
from smoke.model.string_table import String
from smoke.replay.decoder import string_table as rply_dcdr_strngtbl


cpdef handle(pb, match):
    HANDLERS[type(pb)](pb, match)


cpdef handle_dem_fileheader(pb, match):
    cdef object file_header = {
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
    cdef object server_info = {
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
    cdef object con_vars = match.con_vars or dict()

    for cvar in pb.convars.cvars:
        name, value = cvar.name, cvar.value
        con_vars[name] = value

    match.con_vars = con_vars


cpdef handle_svc_createstringtable(pb, match):
    cdef object basis_string_tables = match.basis_string_tables or \
        mdl_cllctn_strngtbl.mk()
    cdef int index = len(basis_string_tables.by_index)
    cdef object string_table = rply_dcdr_strngtbl.decode_and_create(pb)

    basis_string_tables.mapping[index] = string_table
    basis_string_tables.by_name[pb.name] = string_table

    match.basis_string_tables = basis_string_tables


cpdef handle_net_signonstate(pb, match):
    cdef object signon_state = {
        'signon_state': pb.signon_state,
        'spawn_count': pb.spawn_count,
        'num_server_players': pb.num_server_players
    }

    match.signon_state = signon_state

    # 5 indicates complete signon. It's a constant in the Source engine.
    if signon_state['signon_state'] == 5:
        match.flatten_send_tables()
        match.check_sanity()


cpdef handle_svc_sendtable(pb, match):
    cdef object send_tables = match.send_tables or dict()
    cdef object send_props = list()

    cdef object array_prop
    cdef object num_elements
    cdef object num_bits
    cdef object dt_name
    cdef object low_value
    cdef object high_value
    cdef object send_prop
    cdef object needs_decoder

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
    cdef object voice_init = {
        'quality': pb.quality,
        'codec': pb.codec,
        'version': pb.version
    }

    match.voice_init = voice_init


cpdef handle_svc_gameeventlist(pb, match):
    cdef object game_event_descriptors = mdl_cllctn_gmvntdscrptrs.mk()
    cdef int eventid
    cdef object name
    cdef object keys
    cdef object game_event_descriptor

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
    cdef object s
    cdef int d
    cdef int n
    cdef object patch

    match.entities = match.entities or mdl_cllctn_ntts.mk()

    s = io_strm_ntt.mk(pb.entity_data)
    d, n = pb.is_delta, pb.updated_entries
    patch = match.packet_entities_decoder.decode(s, d, n, match.entities)

    match.entities.apply(patch)


cpdef handle_svc_gameevent(pb, match):
    pass


cpdef handle_svc_usermessage(pb, match):
    pass


cpdef handle_svc_updatestringtable(pb, match):
    pass


cpdef handle_svc_tempentities(pb, match):
    pass


cpdef handle_svc_sounds(pb, match):
    pass


cpdef handle_svc_voicedata(pb, match):
    pass


cpdef handle_dem_fileinfo(pb, match):
    pass


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
