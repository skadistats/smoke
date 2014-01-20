import math

from collections import deque, OrderedDict
from smoke.io.stream import generic as io_strm_gnrc
from smoke.model import string_table as mdl_strngtbl
from smoke.model.string_table import String


cdef int MAX_NAME_LENGTH
cdef int KEY_HISTORY_SIZE


cpdef object decode_and_create(object pb)
# def decode_and_apply_update(pb, string_table)
cdef object deserialize(int num_entries, object string_data, object string_table)
cdef object _deserialize_index(object stream, int index, object string_table)
cdef object _deserialize_name(object stream, object mystery_flag, object key_history)
cdef object _deserialize_value(object stream, object string_table)
