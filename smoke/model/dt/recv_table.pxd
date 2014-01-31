

cdef class RecvTable(object):
    cdef public unicode dt
    cdef public list recv_props
    cdef object _by_identifier
