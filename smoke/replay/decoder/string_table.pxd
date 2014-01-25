# cython: profile=False

import math

from smoke.io.stream cimport generic
from smoke.model cimport string_table as mdl_strngtbl


cdef object decode_and_create(object pb)


cdef list decode_update(object pb, mdl_strngtbl.StringTable string_table)


cdef list _deserialize(int num_entries, str string_data, mdl_strngtbl.StringTable string_table)


cdef int _deserialize_index(generic.Stream stream, int index, mdl_strngtbl.StringTable string_table)


cdef str _deserialize_name(generic.Stream stream, int mystery_flag, object key_history)


cdef str _deserialize_value(generic.Stream stream, mdl_strngtbl.StringTable string_table)
