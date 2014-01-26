

cdef int MAX_EDICT_BITS


cdef to_e(int index, int serial)


cdef from_e(int ehandle)


cdef class Collection(object):
    cdef public dict entry_by_index
    cdef public dict recv_table_by_cls
    cdef public dict _entry_by_ehandle
    cdef public dict _entries_by_cls

    cdef void apply(Collection self, list patch, dict baselines)
