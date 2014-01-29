# cython: profile=False


cdef class GameEventDescriptor(object):
    def __cinit__(GameEventDescriptor self, int _id, unicode name, list keys):
        self.id = _id
        self.name = name
        self.keys = keys


cdef class Collection(object):
    def __init__(self):
        self.by_eventid = dict()
        self.by_name = dict()
