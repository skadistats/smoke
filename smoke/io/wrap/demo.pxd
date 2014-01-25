import io
import snappy
import struct

from smoke.io cimport util as io_utl

from smoke.io.const import Peek


cpdef DemoIO mk(object handle)


cdef public object InvalidHeaderError(RuntimeError)


cdef class DemoIO(object):
    cdef public object handle

    cpdef int bootstrap(DemoIO self) except -1

    cpdef object read(DemoIO self)
