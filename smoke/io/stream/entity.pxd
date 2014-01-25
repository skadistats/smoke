from smoke.io.stream cimport generic


cpdef Stream mk(str data)


cdef class Stream(generic.Stream):
    cdef int read_entity_index(Stream self, int base_index)
    cdef int read_entity_pvs(Stream self)
    cdef object read_entity_prop_list(self)
