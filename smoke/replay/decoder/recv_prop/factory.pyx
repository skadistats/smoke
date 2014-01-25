from smoke.replay.decoder.recv_prop cimport darray
from smoke.replay.decoder.recv_prop cimport dfloat
from smoke.replay.decoder.recv_prop cimport dint
from smoke.replay.decoder.recv_prop cimport dint64
from smoke.replay.decoder.recv_prop cimport dstring
from smoke.replay.decoder.recv_prop cimport dvector
from smoke.replay.decoder.recv_prop cimport dvectorxy

from smoke.model.dt.const import Type


cdef int t_array = Type.Array
cdef int t_float = Type.Float
cdef int t_int = Type.Int
cdef int t_int64 = Type.Int64
cdef int t_string = Type.String
cdef int t_vector = Type.Vector
cdef int t_vectorxy = Type.VectorXY


cpdef mk(prop):
    cdef int t = prop.type

    if t == t_array:
        # array props have an embedded prop describing the in-array type
        return darray.mk(prop, mk(prop.array_prop))
    elif t == t_float:
        return dfloat.mk(prop)
    elif t == t_int:
        return dint.mk(prop)
    elif t == t_int64:
        return dint64.mk(prop)
    elif t == t_string:
        return dstring.mk(prop)
    elif t == t_vector:
        return dvector.mk(prop)
    elif t == t_vectorxy:
        return dvectorxy.mk(prop)

    raise NotImplementedError()
