from collections import defaultdict
from smoke.model.const import Entity, PVS


cdef int MAX_EDICT_BITS = 11


cpdef EntitiesCollection mk(object entry_by_index=None, object recv_table_by_cls=None):
    return EntitiesCollection(entry_by_index, recv_table_by_cls)


cdef to_e(int index, int serial):
    return (serial << MAX_EDICT_BITS) | index


cdef from_e(int ehandle):
    index = ehandle & ((1 << MAX_EDICT_BITS) - 1)
    serial = ehandle >> MAX_EDICT_BITS

    return index, serial


cdef class EntitiesCollection(object):
    cdef public object entry_by_index
    cdef public object recv_table_by_cls
    cdef public object _entry_by_ehandle
    cdef public object _entries_by_cls

    def __init__(EntitiesCollection self, object entry_by_index=None, object recv_table_by_cls=None):
        self.entry_by_index = entry_by_index or {}
        self.recv_table_by_cls = recv_table_by_cls or {}
        self._entry_by_ehandle = None
        self._entries_by_cls = None

    def __len__(self):
        return len(self.entry_by_index)

    cpdef apply(EntitiesCollection self, object patch, object baselines):
        entry_by_index = self.entry_by_index

        for pvs, e in patch:
            if pvs == PVS.Enter:
                state = baselines[e.cls].copy()
                state.update(e.state)
                e = Entity(e.index, e.serial, e.cls, state)
                entry_by_index[e.index] = (PVS.Enter, e)
            elif pvs == PVS.Preserve:
                assert e.index in entry_by_index
                peek, entry = entry_by_index[e.index]
                entry.state.update(e.state)
            elif pvs == PVS.Leave:
                _, entry = entry_by_index[e.index]
                entry_by_index[entry.index] = (PVS.Leave, entry)
            elif pvs == PVS.Delete and e.index in entry_by_index:
                del entry_by_index[e.index]

    property entries_by_cls:
        def __get__(self):
            cdef object _entries_by_cls = defaultdict(list)

            if not self._entries_by_cls:
                for _, entry in self.entry_by_index.items():
                    pvs, entity = entry
                    _entries_by_cls[entity.cls] = entry

                self._entries_by_cls = _entries_by_cls

            return self._entries_by_cls

    property entry_by_ehandle:
        def __get__(self):
            cdef object _entry_by_ehandle = dict()

            if not self._entry_by_ehandle:
                for _, entry in self.entry_by_index.items():
                    pvs, entity = entry
                    _entry_by_ehandle[to_e(entity.index, entity.serial)] = entry

                self._entry_by_ehandle = _entry_by_ehandle

            return self._entry_by_ehandle
