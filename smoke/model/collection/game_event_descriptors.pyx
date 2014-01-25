# cython: profile=False

from smoke.model.const import GameEventDescriptor


cpdef GameEventDescriptorsCollection mk():
    return GameEventDescriptorsCollection()


cdef class GameEventDescriptorsCollection(object):
    cdef public dict by_eventid
    cdef public dict by_name

    def __init__(self):
        self.by_eventid = dict()
        self.by_name = dict()
