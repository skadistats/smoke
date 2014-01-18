import math
import snappy

from smoke.model.dt.prop import Prop, Flag
from smoke.replay.decoder.recv_prop import float as rply_dcdr_rcvprp_flt

def mk(prop):
    return VectorDecoder(prop)


class VectorDecoder(object):
    def __init__(self, prop):
        self.prop = prop
        self.normal = prop.flags & Flag.Normal
        self.decoder = rply_dcdr_rcvprp_flt.mk(prop)

    def decode(self, stream):
        x = self.decoder.decode(stream)
        y = self.decoder.decode(stream)

        if self.normal:
            f = x * x + y * y
            z = 0 if (f <= 1) else math.sqrt(1 - f)

            sign = stream.read_numeric_bits(1)
            if sign:
                z *= -1
        else:
            z = self.decoder.decode(stream)

        return x, y, z
