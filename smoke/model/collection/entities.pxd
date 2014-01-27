

cdef int MAX_EDICT_BITS


cdef to_e(int index, int serial)


cdef from_e(int ehandle)


cdef class Collection(object):
    cdef public object by_index
    cdef object _by_ehandle
    cdef object _by_cls

    cdef void invalidate_views(self)