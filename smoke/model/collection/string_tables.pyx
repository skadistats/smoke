import copy


cpdef StringTablesCollection mk():
    return StringTablesCollection()


cdef class StringTablesCollection(object):
    cdef public object by_index
    cdef public object by_name

    def __init__(self):
        self.by_index = dict()
        self.by_name = dict()

    def __add__(self, other):
        cdef StringTablesCollection new = copy.copy(self)

        new.by_index.update(other.by_index)
        new.by_name.update(other.by_name)

        return new

    def __copy__(self):
        cdef StringTablesCollection new = StringTablesCollection()
        
        new.by_index = self.by_index.copy()
        new.by_name = self.by_name.copy()

        return new
