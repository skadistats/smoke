# cython: profile=False


cpdef handle(object pb, rply_mtch.Match match):
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
