import io
import snappy

from smoke.io import util as io_utl
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
            kind = io_utl.read_varint(self.handle)
            size = io_utl.read_varint(self.handle)
            message = self.handle.read(size)

            assert len(message) == size
        except AssertionError:
            raise EOFError()

        return Peek(False, kind, self.tick, size), message
