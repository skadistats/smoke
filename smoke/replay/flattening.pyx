# cython: profile=False

from smoke.model.dt cimport prop as mdl_dt_prp

from collections import deque
from itertools import chain


cpdef list flatten(object descendant, object lookup):
    assert descendant.needs_flattening

    cdef list excl = _aggregate_exclusions(lookup, descendant)
    cdef list rp = list() # shared state within recursion

    _flatten(lookup, rp, excl, descendant, deque()) # rp is mutated

    return rp


def _aggregate_exclusions(object l, object st):
    relations = st.all_relations
    excl = map(lambda sp: _aggregate_exclusions(l, l[sp.dt]), relations)
    return list(st.all_exclusions) + list(chain(*excl))


cdef _flatten(object l, list rp, list excl, object anc, object path, unicode src=None, list acc=None):
    cdef:
        list _acc = acc or list()
        unicode _src = src or u''
        unicode name
        int namelen

    _flatten_collapsible(l, rp, excl, anc, path, _src, _acc)

    name = unicode(''.join(['{}.'.format(_name) for _name in path]))
    namelen = len(name)

    for sp in _acc:
        name += sp.name
        rp.append(mdl_dt_prp.Prop(sp.src, name, sp.type, sp.flags, sp.pri, sp.len, sp.bits, sp.dt, sp.low, sp.high, sp.array_prop))
        name = name[:namelen]


cdef _flatten_collapsible(object l, list rp, list excl, object anc, object path, unicode src, list acc):
    cdef int excluded, ineligible

    for sp in anc.all_non_exclusions:
        excluded = (anc.name, sp.name) in excl
        ineligible = sp.flags & mdl_dt_prp.INSIDEARRAY

        if excluded or ineligible:
            continue

        if sp.type is mdl_dt_prp.DATATABLE:
            if sp.flags & mdl_dt_prp.COLLAPSIBLE:
                _flatten_collapsible(l, rp, excl, l[sp.dt], path, src=src, acc=acc)
            else:
                path.append(sp.name)
                _flatten(l, rp, excl, l[sp.dt], path, src if src else anc.name, list())
                path.pop()
        else:
            acc.append(sp)
