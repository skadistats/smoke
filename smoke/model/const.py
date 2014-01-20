from collections import namedtuple
from smoke.util import enum


PVS = enum(Preserve = 0, Enter = 1 << 0, Leave = 1 << 1, Delete = 0x03)


Entity = namedtuple('Entity', 'index, serial, cls, state')


String = namedtuple('String', 'index, name, value')


GameEventDescriptor = namedtuple('GameEvent', 'id, name, keys')
