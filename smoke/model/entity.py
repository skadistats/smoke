from collections import namedtuple
from smoke.util import enum


PVS = enum(Preserve = 0, Enter = 1 << 0, Leave = 1 << 1, Delete = 0x03)


Entity = namedtuple('Entity', 'index, serial, cls, state')


def to_e(index, serial):
  return (serial << MAX_EDICT_BITS) | index


def from_e(ehandle):
  index = ehandle & ((1 << MAX_EDICT_BITS) - 1)
  serial = ehandle >> MAX_EDICT_BITS
  return index, serial
