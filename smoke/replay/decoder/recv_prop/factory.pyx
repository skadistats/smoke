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


cdef mk(object prop):
    cdef int t = prop.type

    if t == t_array:
        # array props have an embedded prop describing the in-array type
        return darray.Decoder(prop, mk(prop.array_prop))
    elif t == t_float:
        return dfloat.Decoder(prop)
    elif t == t_int:
        return dint.Decoder(prop)
    elif t == t_int64:
        return dint64.Decoder(prop)
    elif t == t_string:
        return dstring.Decoder(prop)
    elif t == t_vector:
        return dvector.Decoder(prop)
    elif t == t_vectorxy:
        return dvectorxy.Decoder(prop)

    raise NotImplementedError()
