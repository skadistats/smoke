import collections as c


Peek = c.namedtuple('Peek', 'compressed, kind, tick, size')


class VarintTooLongError(RuntimeError):
    pass


VI_MAX_BYTES, VI_SHIFT = 5, 7
VI_MASK = (1 << 32) - 1


def read_varint(handle):
    size, value, shift = 0, 0, 0

    while True:
        byte = handle.read(1)

        if len(byte) == 0:
            raise EOFError()

        size += 1
        value |= (ord(byte) & 0x7f) << shift
        shift += VI_SHIFT

        if not (ord(byte) & 0x80):
            return value & VI_MASK

        if shift >= VI_SHIFT * VI_MAX_BYTES:
            raise VarintTooLongError()
