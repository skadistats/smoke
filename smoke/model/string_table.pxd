# cython: profile=False


cdef class StringTable(object):
    cdef public unicode name
    cdef public int max_entries
    cdef public int user_data_fixed_size
    cdef public int user_data_size_bits
    cdef public int entry_sz_bits
    cdef public dict by_name
    cdef public dict by_index

    cdef update(StringTable self, object string)
