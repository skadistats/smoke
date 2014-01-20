from libc.stdint cimport int64_t, uint64_t, uint32_t
from cpython cimport array


cpdef Stream mk(str data)


cdef class Stream(object):
    cdef public int pos
    cdef int lenwords
    cdef uint32_t *words

    cpdef _init_data(Stream self, array.array[unsigned int] ary)
    cdef _dealloc(Stream self)
    cpdef int read_numeric_bits(self, int n)
    cpdef bytes read_bits(Stream self, int bitlength)
    cpdef bytes read_string(Stream self, int bytelength)
    cpdef int read_varint(Stream self)
