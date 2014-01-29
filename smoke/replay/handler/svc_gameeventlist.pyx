# cython: profile=False

from smoke.model.collection cimport game_event_descriptors as mdl_cllctn_gmvntdscrptrs


cpdef handle(object pb, rply_mtch.Match match):
    cdef:
        mdl_cllctn_gmvntdscrptrs.Collection game_event_descriptors = \
            mdl_cllctn_gmvntdscrptrs.Collection()
        mdl_cllctn_gmvntdscrptrs.GameEventDescriptor game_event_descriptor
        list keys
        int eventid
        unicode name

    for desc in pb.descriptors:
        eventid, name = desc.eventid, desc.name
        keys = [(k.type, k.name) for k in desc.keys]
        game_event_descriptor = \
            mdl_cllctn_gmvntdscrptrs.GameEventDescriptor(eventid, name, keys)
        game_event_descriptors.by_eventid[eventid] = game_event_descriptor
        game_event_descriptors.by_name[name] = game_event_descriptor

    match.game_event_descriptors = game_event_descriptors
