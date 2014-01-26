# cython: profile=False

import copy


cdef class Collection(object):
    def __init__(self):
        self.by_index = dict()
        self.by_name = dict()

    def __add__(self, other):
        cdef Collection new = copy.copy(self)

        new.by_index.update(other.by_index)
        new.by_name.update(other.by_name)

        return new

    def __copy__(self):
        cdef Collection new = Collection()
        
        new.by_index = self.by_index.copy()
        new.by_name = self.by_name.copy()

        return new
