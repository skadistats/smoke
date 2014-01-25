from libc.stdint cimport int64_t, uint64_t, uint32_t
from cpython cimport array


cpdef Stream mk(str data)


cdef class Stream(object):
    cdef public int pos
    cdef int lenwords
    cdef uint32_t *words

    cdef int _init_data(Stream self, array.array[unsigned int] ary) except -1
    cdef int _dealloc(Stream self) except -1
    cdef int read_numeric_bits(self, int n)
    cdef bytes read_bits(Stream self, int bitlength)
    cdef bytes read_string(Stream self, int bytelength)
    cdef int read_varint(Stream self)
