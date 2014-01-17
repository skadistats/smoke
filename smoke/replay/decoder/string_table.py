import math

from collections import deque, OrderedDict
from smoke.io.stream import generic as io_strm_gnrc
from smoke.model import string_table as mdl_strngtbl
from smoke.model.string_table import String


MAX_NAME_LENGTH = 0x400
KEY_HISTORY_SIZE = 32


def decode_and_create(pb):
    udfs, udsb = pb.user_data_fixed_size, pb.user_data_size_bits

    string_table = mdl_strngtbl.mk(pb.name, pb.max_entries, udfs, udsb)

    for string in deserialize(pb.num_entries, pb.string_data, udfs, udsb):
        string_table.update(string)

    return string_table


# def decode_and_apply_update(pb, string_table):
#     update = deserialize(pb.num_changed_entries, pb.string_data, \
#         string_table.user_data_fixed_size, string_table.user_data_size_bits)

#     for string in update:
#         string_table.update(string)

#     return update


def deserialize(num_entries, string_data, udfs, udsb):
    stream = io_strm_gnrc.mk(string_data)

    # The meaning of this one-bit flag is unknown, but we can use it later
    # for sanity checks. It corresponds to unimplemented string table
    # functionality in combination with other bits parsed later.
    mystery_flag = stream.read_numeric_bits(1)
    key_history = deque()
    index = -1

    diff = []

    while len(diff) < num_entries:
        index = _deserialize_index(stream, index)
        name = _deserialize_name(stream, mystery_flag, key_history)
        value = _deserialize_value(stream, udfs, udsb)
        diff.append(String(index, name, value))

    return diff


def _deserialize_index(stream, index):
    # first bit indicates whether the index is consecutive
    if stream.read_numeric_bits(1):
        index += 1
    else:
        index = stream.read_numeric_bits(entry_sz_bits)

    return index


def _deserialize_name(stream, mystery_flag, key_history):
    name = None

    # first bit indicates whether the entry has a name
    if stream.read_numeric_bits(1):
        # no idea what these bits mean, but certain value combinations
        # indicate unimplemented string table functionality
        assert not (mystery_flag and stream.read_numeric_bits(1))

        # first bit indicates whether string name based on key history
        if stream.read_numeric_bits(1):
            basis = stream.read_numeric_bits(5)
            length = stream.read_numeric_bits(5)
            name = key_history[basis][0:length]
            name += stream.read_string(MAX_NAME_LENGTH - length)
        else:
            name = stream.read_string(MAX_NAME_LENGTH)

        if len(key_history) == KEY_HISTORY_SIZE:
            key_history.popleft()

        key_history.append(name)

    return name


def _deserialize_value(stream, user_data_fixed_size, user_data_size_bits):
    value = ''

    # first bit indicates whether the entry has a value
    if stream.read_numeric_bits(1):
        if user_data_fixed_size:
            bit_length = user_data_size_bits
        else:
            bit_length = stream.read_numeric_bits(14) * 8

        value = stream.read_bits(bit_length)

    return value
