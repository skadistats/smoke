

cdef int VI_MAX_BYTES
cdef int VI_SHIFT
cdef int VI_MASK

cpdef int read_varint(object handle) except -1
