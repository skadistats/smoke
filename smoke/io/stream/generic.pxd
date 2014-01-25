from libc.stdint cimport int64_t, uint64_t, uint32_t
from cpython cimport array


cdef class Stream(object):
    cdef public int pos
    cdef uint32_t *words

    cdef public int read_numeric_bits(self, int n)
    cdef public str read_bits(Stream self, int bitlength)
    cdef public str read_string(Stream self, int bytelength)
    cdef public int read_varint(Stream self)
