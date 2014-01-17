import copy

from collections import namedtuple


def mk():
    return StringTablesCollection()


class StringTablesCollection(object):
    def __init__(self):
        self.mapping = dict()
        self.by_index = dict()
        self.by_name = dict()

    def __add__(self, other):
        new = copy.copy(self)

        new.mapping.update(other.mapping)
        new.by_index.update(other.by_index)
        new.by_name.update(other.by_name)

        return StringTablesCollection(old)

    def __copy__(self):
        new = StringTablesCollection()

        new.mapping = self.mapping.copy()
        new.by_index = self.by_index.copy()
        new.by_name = self.by_name.copy()

        return new