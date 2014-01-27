# cython: profile=False

from smoke.model.dt cimport prop as mdl_dt_prp

from smoke.replay.decoder.recv_prop cimport abstract as rply_dcdr_bstrct
from smoke.replay.decoder.recv_prop cimport darray
from smoke.replay.decoder.recv_prop cimport dfloat
from smoke.replay.decoder.recv_prop cimport dint
from smoke.replay.decoder.recv_prop cimport dint64
from smoke.replay.decoder.recv_prop cimport dstring
from smoke.replay.decoder.recv_prop cimport dvector
from smoke.replay.decoder.recv_prop cimport dvectorxy


cdef class Prop(object):
    def __cinit__(self, unicode src, unicode name, int _type, int flags, int pri, int _len, int bits, unicode dt, float low, float high, Prop array_prop):
        self.src = src
        self.name = name
        self.type = _type
        self.flags = flags
        self.pri = pri
        self.len = _len
        self.bits = bits
        self.dt = dt
        self.low = low
        self.high = high
        self.array_prop = array_prop

    cdef rply_dcdr_bstrct.Decoder mk(Prop self):
        cdef mdl_dt_prp.Prop array_prop

        if self.type == mdl_dt_prp.ARRAY:
            array_prop = <mdl_dt_prp.Prop>self.array_prop
            return darray.Decoder(self, array_prop.mk())
        elif self.type == mdl_dt_prp.FLOAT:
            return dfloat.Decoder(self)
        elif self.type == mdl_dt_prp.INT:
            return dint.Decoder(self)
        elif self.type == mdl_dt_prp.INT64:
            return dint64.Decoder(self)
        elif self.type == mdl_dt_prp.STRING:
            return dstring.Decoder(self)
        elif self.type == mdl_dt_prp.VECTOR:
            return dvector.Decoder(self)
        elif self.type == mdl_dt_prp.VECTORXY:
            return dvectorxy.Decoder(self)

        raise NotImplementedError()
