from collections import namedtuple
from smoke.util import enum


Action = enum(Enqueue = 0, Inline = 1, Ignore = 2)


Peek = namedtuple('Peek', 'compressed, kind, tick, size')


class DEMSyncTickEncountered(RuntimeError):
    pass


class DEMStopEncountered(RuntimeError):
    pass
