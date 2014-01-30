from smoke.model.dt cimport prop as mdl_dt_prp


cdef class Decoder(object):
    cdef public mdl_dt_prp.Prop prop
