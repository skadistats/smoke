import math

from smoke.io.stream cimport generic as io_strm_gnrc

from collections import deque, OrderedDict
from smoke.model import string_table as mdl_strngtbl
from smoke.model.string_table import String


cdef int MAX_NAME_LENGTH
cdef int KEY_HISTORY_SIZE


cpdef object decode_and_create(object pb)
cpdef object decode_update(pb, string_table)
cdef object _deserialize(int num_entries, object string_data, object string_table)
cdef object _deserialize_index(io_strm_gnrc.Stream stream, int index, object string_table)
cdef object _deserialize_name(io_strm_gnrc.Stream stream, object mystery_flag, object key_history)
cdef object _deserialize_value(io_strm_gnrc.Stream stream, object string_table)
