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

    def __init__(self, dt, recv_props):
        self._by_name = None

    def __len__(self):
        return len(self.recv_props)

    def __iter__(self):
        return iter(self.recv_props)
