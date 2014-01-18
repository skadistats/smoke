from collections import defaultdict
from smoke.model.entity import Entity, PVS, to_e, from_e


MAX_EDICT_BITS = 11


def mk(**kwargs):
    return EntitiesCollection(*kwargs)


class EntitiesCollection(object):
    def __init__(self, entry_by_index=None):
        self.entry_by_index = entry_by_index or {}
        self._entry_by_ehandle = None
        self._entries_by_cls = None

    def __len__(self):
        return len(self.entry_by_index)

    def apply(self, patch):
        entry_by_index = self.entry_by_index

        for pvs, e in patch:
            if pvs == PVS.Enter:
                entry_by_index[e.index] = (PVS.Enter, e)
            elif pvs == PVS.Preserve:
                assert e.index in entry_by_index
                peek, entry = entry_by_index[e.index]
                state = entry.state.copy()
                state.update(e.state)
                entry = (peek, Entity(e.index, e.serial, e.cls, state))
                entry_by_index[e.index] = entry
            elif pvs == PVS.Leave:
                _, e = entry_by_index[e.index]
                entry_by_index[e.index] = (PVS.Leave, e)
            elif pvs == PVS.Delete and e.index in entry_by_index:
                del entry_by_index[e.index]

    @property
    def entries_by_cls(self):
        if not self._entries_by_cls:
            _entries_by_cls = c.defaultdict(list)

            for _, entry in self.entry_by_index.items():
                pvs, entity = entry
                _entries_by_cls[entity.cls] = entry

            self._entries_by_cls = _entries_by_cls

        return self._entries_by_cls

    @property
    def entry_by_ehandle(self):
        if not self._entry_by_ehandle:
            _entry_by_ehandle = dict()

            for _, entry in self.entry_by_index.items():
                pvs, e = entry
                _entry_by_ehandle[to_e(e.index, e.serial)] = entry

            self._entry_by_ehandle = _entry_by_ehandle

        return self._entry_by_ehandle
