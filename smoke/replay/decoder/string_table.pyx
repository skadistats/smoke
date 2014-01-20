import math

from collections import deque, OrderedDict
from smoke.io.stream import generic as io_strm_gnrc
from smoke.model import string_table as mdl_strngtbl
from smoke.model.string_table import String


cdef int MAX_NAME_LENGTH = 0x400
cdef int KEY_HISTORY_SIZE = 32


cpdef object decode_and_create(object pb):
    cdef int udfs = pb.user_data_fixed_size
    cdef int udsb = pb.user_data_size_bits
    cdef object string_table = mdl_strngtbl.mk(pb.name, pb.max_entries, udfs, udsb)

    for string in deserialize(pb.num_entries, pb.string_data, string_table):
        string_table.update(string)

    return string_table


# def decode_and_apply_update(pb, string_table):
#     update = deserialize(pb.num_changed_entries, pb.string_data, \
#         string_table.user_data_fixed_size, string_table.user_data_size_bits)

#     for string in update:
#         string_table.update(string)

#     return update


cdef object deserialize(int num_entries, object string_data, object string_table):
    cdef object stream = io_strm_gnrc.mk(string_data)

    # The meaning of this one-bit flag is unknown, but we can use it later
    # for sanity checks. It corresponds to unimplemented string table
    # functionality in combination with other bits parsed later.
    cdef object mystery_flag = stream.read_numeric_bits(1)
    cdef object key_history = deque()
    cdef int index = -1

    cdef object diff = []
    cdef object name, value

    while len(diff) < num_entries:
        index = _deserialize_index(stream, index, string_table)
        name = _deserialize_name(stream, mystery_flag, key_history)
        value = _deserialize_value(stream, string_table)
        diff.append(String(index, name, value))

    return diff


cdef object _deserialize_index(object stream, int index, object string_table):
    # first bit indicates whether the index is consecutive
    if stream.read_numeric_bits(1):
        index += 1
    else:
        index = stream.read_numeric_bits(string_table.entry_sz_bits)

    return index


cdef object _deserialize_name(object stream, object mystery_flag, object key_history):
    cdef object name = None
    cdef int basis, length

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


cdef object _deserialize_value(object stream, object string_table):
    cdef object value = ''

    # first bit indicates whether the entry has a value
    if stream.read_numeric_bits(1):
        if string_table.user_data_fixed_size:
            bit_length = string_table.user_data_size_bits
        else:
            bit_length = stream.read_numeric_bits(14) * 8

        value = stream.read_bits(bit_length)

    return value
