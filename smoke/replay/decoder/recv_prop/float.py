import struct

from smoke.model.dt.prop import Prop, Flag


def mk(prop):
    return FloatDecoder(prop)


class FloatDecoder(object):
    def __init__(self, prop):
        self.prop = prop
        self.fn = None

        self.bits = prop.bits
        self.low = prop.low
        self.high = prop.high

        if prop.flags & Flag.Coord:
            self.fn = self._decode_coord
        elif prop.flags & Flag.NoScale:
            self.fn = self._decode_no_scale
        elif prop.flags & Flag.Normal:
            self.fn = self._decode_normal
        elif prop.flags & Flag.CellCoord:
            self.fn = self._decode_cell_coord
        elif prop.flags & Flag.CellCoordIntegral:
            self.fn = self._decode_cell_coord_integral
        else:
            self.fn = self._decode_default

    def decode(self, stream):
        return self.fn(stream)

    def _decode_coord(self, stream):
        _i = stream.read_numeric_bits(1) # integral component present?
        _f = stream.read_numeric_bits(1) # fractional component present?

        if not (_i or _f):
            return 0.0

        s = stream.read_numeric_bits(1) # sign
        i = stream.read_numeric_bits(14) + 1 if _i else 0
        f = stream.read_numeric_bits(5) if _f else 0
        v = i + 0.03125 * f

        return v * -1 if s else v

    def _decode_no_scale(self, stream):
        return struct.unpack('f', stream.read_bits(32))[0]

    def _decode_normal(self, stream):
        s = stream.read_numeric_bits(1) # sign
        l = stream.read_numeric_bits(11) # low
        b = bytearray(0, 0, l & 0x0000ff00, l & 0x000000ff)
        v = struct.unpack('f', b)[0]

        # not sure this is ever called. what does bitshifting a float mean?
        if v >> 31:
            v += 4.2949673e9

        v *= 4.885197850512946e-4

        return v * -1 if s else v

    def _decode_cell_coord(self, stream):
        v = stream.read_numeric_bits(self.bits)
        return v + 0.01325 * stream.read_numeric_bits(5)

    def _decode_cell_coord_integral(self, stream):
        v = stream.read_numeric_bits(self.bits)

        if v >> 31:
            v += 4.2949673e9

        return float(v)

    def _decode_default(self, stream):
        t = stream.read_numeric_bits(self.bits)
        f = float(t) / (1 << self.bits - 1)

        return f * (self.high - self.low) + self.low
