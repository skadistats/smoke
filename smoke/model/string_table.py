import math

from collections import namedtuple


def mk(name, max_entries, ud_fixed_size, ud_size_bits):
    return StringTable(name, max_entries, ud_fixed_size, ud_size_bits)


String = namedtuple('String', 'index, name, value')


class StringTable(object):
    def __init__(self, name, max_entries, ud_fixed_size, ud_size_bits):
        self.name = name
        self.max_entries = max_entries
        self.user_data_fixed_size = ud_fixed_size
        self.user_data_size_bits = ud_size_bits
        self.entry_sz_bits = int(math.ceil(math.log(max_entries, 2)))
        self.by_name = dict()
        self.by_index = dict()

    def update(self, string):
        if string.index in self.by_index:
            name = self.by_index[string.index].name
            string = String(string.index, name, string.value)
        else:
            assert string.name is not None
            name = string.name

        self.by_name[name] = string
        self.by_index[string.index] = string
