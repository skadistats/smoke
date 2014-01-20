from smoke.model.dt.prop import Type
from smoke.replay.decoder.recv_prop import darray as rply_dcdr_rcvprp_ry
from smoke.replay.decoder.recv_prop import dfloat as rply_dcdr_rcvprp_flt
from smoke.replay.decoder.recv_prop import dint as rply_dcdr_rcvprp_nt
from smoke.replay.decoder.recv_prop import dint64 as rply_dcdr_rcvprp_nt64
from smoke.replay.decoder.recv_prop import dstring as rply_dcdr_rcvprp_strng
from smoke.replay.decoder.recv_prop import dvector as rply_dcdr_rcvprp_vctr
from smoke.replay.decoder.recv_prop import dvectorxy as \
    rply_dcdr_rcvprp_vctrxy


MODULES_BY_TYPE = {
    Type.Array: rply_dcdr_rcvprp_ry,
    Type.Float: rply_dcdr_rcvprp_flt,
    Type.Int: rply_dcdr_rcvprp_nt,
    Type.Int64: rply_dcdr_rcvprp_nt64,
    Type.String: rply_dcdr_rcvprp_strng,
    Type.Vector: rply_dcdr_rcvprp_vctr,
    Type.VectorXY: rply_dcdr_rcvprp_vctrxy
}


def mk(prop):
    try:
        if prop.type is Type.Array:
            # array props have an embedded prop describing the in-array type
            array_prop = prop.array_prop
            apd = MODULES_BY_TYPE[array_prop.type].mk(array_prop)
            return rply_dcdr_rcvprp_ry.mk(prop, apd)
        return MODULES_BY_TYPE[prop.type].mk(prop)
    except KeyError:
        raise NotImplementedError()
