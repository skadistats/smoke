

cdef class SendTable(object):
    cdef public unicode name
    cdef public list send_props
    cdef public object needs_flattening
