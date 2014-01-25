from smoke.io.stream cimport generic


cdef class Stream(generic.Stream):
    cdef int read_entity_index(Stream self, int base_index)
    cdef int read_entity_pvs(Stream self)
    cdef list read_entity_prop_list(Stream self)
