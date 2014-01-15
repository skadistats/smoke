import importlib as il
import io
import os
import snappy

__impl__ = 'smoke_ext' if os.environ.get('SMOKE_EXT') else 'smoke'
io_util = il.import_module(__impl__ + '.io.util')

from smoke.io.util import Peek


def mk(data, tick=0):
    handle = io.BufferedReader(io.BytesIO(data))
    return EmbedIO(handle, tick=tick)


class EmbedIO(object):
    def __init__(self, handle, tick=0):
        self.handle = handle
        self.tick = tick

    def __iter__(self):
        while True:
            try:
                yield self.read()
            except EOFError:
                raise StopIteration()

    def read(self):
        try:
            kind = io_util.read_varint(self.handle)
            size = io_util.read_varint(self.handle)
            message = self.handle.read(size)

            assert len(message) == size
        except AssertionError:
            raise EOFError()

        return Peek(False, kind, self.tick, size), message
