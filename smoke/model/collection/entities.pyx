# cython: profile=False

from collections import defaultdict


cdef int MAX_EDICT_BITS = 11


cdef to_e(int index, int serial):
    return (serial << MAX_EDICT_BITS) | index


cdef from_e(int ehandle):
    index = ehandle & ((1 << MAX_EDICT_BITS) - 1)
    serial = ehandle >> MAX_EDICT_BITS

    return index, serial


cdef class Collection(object):
    def __init__(Collection self, object by_index=None):
        self.by_index = by_index or defaultdict(None)
        self._by_ehandle = None
        self._by_cls = None

    def __len__(self):
        return len(self.by_index)

    cdef void invalidate_views(self):
        self._by_ehandle = None
        self._by_cls = None

    property by_ehandle:
        def __get__(self):
            if self._by_ehandle is None:
                # FIXME: Generate.
                pass

            return self._by_ehandle

    property by_cls:
        def __get__(self):
            if self._by_cls is None:
                # FIXME: Generate.
                pass

            return self._by_cls
