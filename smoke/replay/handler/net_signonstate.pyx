# cython: profile=False

from smoke.io.stream cimport entity as io_strm_ntt

from smoke.protobuf import dota2_palm as pbd2


cpdef handle(object pb, rply_mtch.Match match):
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

        active_modifiers = match.string_tables.by_name['ActiveModifiers']

        for string in active_modifiers.by_index.values():
            if len(string.value) == 0:
                continue
            _pb = pbd2.CDOTAModifierBuffTableEntry(string.value)
            assert _pb.entry_type == pbd2.DOTA_MODIFIER_ENTRY_TYPE_ACTIVE
            match.modifiers[_pb.parent][_pb.index] = _pb
