import importlib as il
import os
import snappy

__impl__ = 'smoke_ext' if os.environ.get('SMOKE_EXT') else 'smoke'
io_util = il.import_module(__impl__ + '.io.util')

from smoke.io.util import Peek


COMPRESSED_MASK = 0b01110000
LEN_HEADER = 8
LEN_OFFSET = 4


def mk(handle):
    return DemoIO(handle)


class InvalidHeaderError(RuntimeError):
    pass


class DemoIO(object):
    def __init__(self, handle):
        self.handle = handle

    def __iter__(self):
        while True:
            try:
                yield self.read()
            except EOFError:
                raise StopIteration()

    def bootstrap(self):
        header = self.handle.read(LEN_HEADER)
        offset = self.handle.read(LEN_OFFSET)
        if header != 'PBUFDEM\0':
            raise InvalidHeaderError

        gio = bytearray(offset)

        return sum(gio[i] << (i * 8) for i in range(4))

    def read(self):
        try:
            kind = io_util.read_varint(self.handle)
            comp = bool(kind & COMPRESSED_MASK)
            kind = (kind & ~COMPRESSED_MASK) if comp else kind
            tick = io_util.read_varint(self.handle)
            size = io_util.read_varint(self.handle)
            message = self.handle.read(size)

            assert len(message) == size

            if comp:
                message = snappy.uncompress(message)
        except AssertionError:
            raise EOFError()

        return Peek(comp, kind, tick, size), message
