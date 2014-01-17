from collections import defaultdict
from smoke.model.dt.prop import Flag


def _sorted(recv_props):
    recv_props = list(recv_props) # copy
    priorities = sorted(set([rp.pri for rp in recv_props] + [64]))
    offset = 0

    for priority in priorities:
        hole, cursor = offset, offset

        while cursor < len(recv_props):
            recv_prop = recv_props[cursor]

            flagged_changes_often = recv_prop.flags & Flag.ChangesOften
            changes_often = flagged_changes_often and priority is 64

            if changes_often or recv_prop.pri == priority:
                recv_props[hole], recv_props[cursor] = \
                    recv_props[cursor], recv_props[hole]
                hole, offset = hole + 1, offset + 1

            cursor += 1

    return recv_props


def mk(dt, recv_props):
    return RecvTable(dt, _sorted(recv_props))


class RecvTable(object):
    def __init__(self, dt, recv_props):
        self.dt = dt
        self._recv_props = recv_props

        self._by_src = None
        self._by_name = None
        self._by_tuple = None

    def __iter__(self):
        return iter(self._recv_props)

    @property
    def by_index(self):
        return self._recv_props

    @property
    def by_src(self):
        if self._by_src is None:
            self._by_src = defaultdict(list)

            for i, recv_prop in enumerate(self):
                self._by_src[recv_prop.src].append((i, recv_prop))

        return self._by_src

    @property
    def by_name(self):
        if self._by_name is None:
            self._by_name = defaultdict(list)

            for i, recv_prop in enumerate(self):
                self._by_name[recv_prop.name].append((i, recv_prop))

        return self._by_name

    @property
    def by_tuple(self):
        if self._by_tuple is None:
            self._by_tuple = dict()

            for i, recv_prop in enumerate(self):
                _tuple = (recv_prop.src, recv_prop.name)
                self._by_tuple[_tuple] = (i, recv_prop)

        return self._by_tuple
