from cpython.ref cimport PyObject
from smoke.model cimport entity as mdl_ntt


cdef int ENTITY_BITS
cdef int ENTITY_LIMIT


cdef to_e(int index, int serial)


cdef from_e(int ehandle)


cdef class Collection(object):
    cdef PyObject **_store
    cdef dict _by_index
    cdef dict _by_ehandle
    cdef dict _by_cls

    cdef mdl_ntt.Entity get(Collection self, int index)

    cdef put(Collection self, int index, mdl_ntt.Entity entity)

    cdef delete(Collection self, int index)

    cdef invalidate_views(Collection self)
