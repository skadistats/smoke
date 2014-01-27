from collections import namedtuple
from smoke.util import enum


String = namedtuple('String', 'index, name, value')


GameEventDescriptor = namedtuple('GameEvent', 'id, name, keys')
