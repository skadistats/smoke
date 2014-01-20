from smoke.model.const import GameEventDescriptor


cpdef GameEventDescriptorsCollection mk():
    return GameEventDescriptorsCollection()


cdef class GameEventDescriptorsCollection(object):
    cdef public object by_eventid
    cdef public object by_name

    def __init__(self):
        self.by_eventid = dict()
        self.by_name = dict()
