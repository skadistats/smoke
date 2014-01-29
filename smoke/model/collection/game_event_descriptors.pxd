

cdef class GameEventDescriptor(object):
    cdef:
        public int id
        public unicode name
        public list keys


cdef class Collection(object):
    cdef:
        public dict by_eventid
        public dict by_name
