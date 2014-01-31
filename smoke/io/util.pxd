from libc.stdint cimport uint64_t


cdef:
    int VI_MAX_BYTES
    int VI_SHIFT
    uint64_t VI_MASK

cdef uint64_t read_varint(object handle) except -1
