# cython: profile=False

from smoke.model.const import GameEventDescriptor


cdef class Collection(object):
    def __init__(self):
        self.by_eventid = dict()
        self.by_name = dict()
