# cython: profile=False

from smoke.model.collection cimport game_event_descriptors as mdl_cllctn_gmvntdscrptrs


cpdef handle(object pb, rply_mtch.Match match):
    cdef:
        game_event_descriptor = match.game_event_descriptors.by_eventid[pb.eventid]
        list attrs = list()
        tuple key
        object pbkey, value
        int _type
        unicode name

    for i in range(len(game_event_descriptor.keys)):
        _type, name = game_event_descriptor.keys[i]
        pbkey = pb.keys[i]

        if _type == 1:
            value = pbkey.val_string
        elif _type == 2:
            value = pbkey.val_float
        elif _type == 3:
            value = pbkey.val_long
        elif _type == 4:
            value = pbkey.val_short
        elif _type == 5:
            value = pbkey.val_byte
        elif _type == 6:
            value = pbkey.val_bool
        elif _type == 7:
            value = pbkey.val_uint64

        attrs.append(value)

    match.game_events[pb.eventid].append(attrs)
