from smoke.replay import handler
from smoke.io import plexer as io_plxr


def mk(plexer, match):
    return Ticker(plexer, match)


cdef class Ticker(object):
    cdef public object plexer
    cdef public object match

    def __init__(self, plexer, match):
        self.plexer = plexer
        self.match = match

    def __iter__(self):
        cdef object collection

        while True:
            try:
                collection = self.plexer.read_tick()

                for _, pb in collection:
                    handler.handle(pb, self.match)

                yield self.match
            except io_plxr.DEMStopEncountered:
                raise StopIteration()
