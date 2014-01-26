# cython: profile=False

from collections import defaultdict
from smoke.model.dt.const import Flag


cdef class RecvTable(object):
    def __cinit__(self, dt, recv_props):
        cdef list priorities
        cdef int offset = 0
        cdef int hole, cursor
        cdef object recv_prop
        cdef int flagged_changes_often, changes_often

        recv_props = list(recv_props) # copy
        priorities = sorted(set([rp.pri for rp in recv_props] + [64]))

        for priority in priorities:

            hole = cursor = offset

            while cursor < len(recv_props):
                recv_prop = recv_props[cursor]
                flagged_changes_often = recv_prop.flags & Flag.ChangesOften
                changes_often = flagged_changes_often and priority is 64

                if changes_often or recv_prop.pri == priority:
                    recv_props[hole], recv_props[cursor] = \
                        recv_props[cursor], recv_props[hole]
                    hole, offset = hole + 1, offset + 1

                cursor += 1

        self.dt = dt
        self.recv_props = recv_props

    def __iter__(self):
        return iter(self.recv_props)

    def __init__(self, dt, recv_props):
        self._by_src = None
        self._by_name = None
        self._by_tuple = None

    def __iter__(self):
        return iter(self.recv_props)

    property by_index:
        def __get__(self):
            return self.recv_props

    property by_src:
        def __get__(self):
            if self._by_src is None:
                self._by_src = defaultdict(list)

                for i, recv_prop in enumerate(self):
                    self._by_src[recv_prop.src].append((i, recv_prop))

            return self._by_src

    property by_name:
        def __get__(self):
            if self._by_name is None:
                self._by_name = defaultdict(list)

                for i, recv_prop in enumerate(self):
                    self._by_name[recv_prop.name].append((i, recv_prop))

            return self._by_name

    property by_tuple:
        def __get__(self):
            if self._by_tuple is None:
                self._by_tuple = dict()

                for i, recv_prop in enumerate(self):
                    _tuple = (recv_prop.src, recv_prop.name)
                    self._by_tuple[_tuple] = (i, recv_prop)

            return self._by_tuple
