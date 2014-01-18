from smoke.model.dt.prop import Prop, Flag


def mk(prop):
    return Int64Decoder(prop)


class Int64Decoder(object):
    def __init__(self, prop):
        self.prop = prop

        assert prop.flags ^ Flag.EncodedAgainstTickcount

        self.unsigned = prop.flags & Flag.Unsigned
        self.bits = prop.bits

    def decode(self, stream):
        negate = False
        remainder = self.bits - 32

        if not self.unsigned:
            remainder -= 1
            if stream.read_numeric_bits(1):
                negate = True

        l = stream.read_numeric_bits(32)
        r = stream.read_numeric_bits(remainder)
        v = (l << 32) | r

        if negate:
            v *= -1

        return v
