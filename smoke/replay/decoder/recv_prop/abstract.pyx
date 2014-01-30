# cython: profile=False

from smoke.model.dt cimport prop as mdl_dt_prp


cdef class Decoder(object):
    def __init__(self, mdl_dt_prp.Prop prop):
        self.prop = prop
