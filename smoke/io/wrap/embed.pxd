# cython: profile=False

import io
import snappy
import struct

from smoke.io cimport util as io_utl
from smoke.io.const import Peek


cpdef EmbedIO mk(str data, int tick=?)


cdef class EmbedIO(object):
    cdef public object handle
    cdef public int tick

    cpdef object read(self)