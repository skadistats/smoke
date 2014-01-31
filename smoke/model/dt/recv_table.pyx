# cython: profile=False

from collections import defaultdict, OrderedDict
from smoke.model.dt cimport prop as mdl_dt_prp


cdef class RecvTable(object):
    def __cinit__(RecvTable self, unicode dt, list recv_props):
        cdef:
            list priorities
            int offset = 0
            int hole, cursor
            object recv_prop
            int flagged_changes_often, changes_often

        recv_props = list(recv_props) # copy
        priorities = sorted(set([rp.pri for rp in recv_props] + [64]))

        for priority in priorities:
            hole = cursor = offset

            while cursor < len(recv_props):
                recv_prop = recv_props[cursor]
                flagged_changes_often = recv_prop.flags & mdl_dt_prp.CHANGESOFTEN
                changes_often = flagged_changes_often and priority is 64

                if changes_often or recv_prop.pri == priority:
                    recv_props[hole], recv_props[cursor] = \
                        recv_props[cursor], recv_props[hole]
                    hole, offset = hole + 1, offset + 1

                cursor += 1

        self.dt = dt
        self.recv_props = recv_props
        self._by_identifier = None

    def __init__(RecvTable self, unicode dt, list recv_props):
        self._by_identifier = None

    def __len__(RecvTable self):
        return len(self.recv_props)

    def __iter__(RecvTable self):
        return iter(self.recv_props)

    property by_identifier:
        def __get__(RecvTable self):
            if self._by_identifier is None:
                by_identifier = OrderedDict()

                for recv_prop in self:
                    by_identifier[(recv_prop.src, recv_prop.name)] = recv_prop

                self._by_identifier = by_identifier

            return self._by_identifier
