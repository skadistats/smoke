from smoke.model.dt.prop import Prop, Flag


def mk(prop):
    return IntDecoder(prop)


class IntDecoder(object):
    def __init__(self, prop):
        self.prop = prop

        self.eat = prop.flags & Flag.EncodedAgainstTickcount
        self.unsigned = prop.flags & Flag.Unsigned
        self.bits = prop.bits

    def decode(self, stream):
        if self.eat:
            # this integer is encoded against tick count (?)...
            # in this case, we read a protobuf-style varint
            v = stream.read_varint()

            if self.unsigned:
                return v # as is -- why?

            # ostensibly, this is the "decoding" part in signed cases
            return (-(v & Flag.Unsigned)) ^ (v >> Flag.Unsigned)

        v = stream.read_numeric_bits(self.bits)
        s = (0x80000000 >> (32 - self.bits)) & (self.unsigned - Flag.Unsigned)

        return (v ^ s) - s
