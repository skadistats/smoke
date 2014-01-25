# cython: profile=False

from itertools import chain
from smoke.model.dt.const import Flag, Type, Prop


cpdef list flatten(object descendant, object lookup):
    assert descendant.needs_flattening

    cdef list excl = _aggregate_exclusions(lookup, descendant)
    cdef list rp = [] # shared state within recursion

    _flatten(lookup, rp, excl, descendant) # recv_props is mutated

    return rp


def _aggregate_exclusions(object l, object st):
    relations = st.all_relations
    excl = map(lambda sp: _aggregate_exclusions(l, l[sp.dt]), relations)
    return list(st.all_exclusions) + list(chain(*excl))


cdef _flatten(object l, object rp, object excl, object anc, object acc=None, object prx=None):
    cdef list _acc = acc or []
    cdef object n, s

    _flatten_collapsible(l, rp, excl, anc, _acc)

    for sp in _acc:
        if prx:
            n = '{}.{}'.format(sp[0], sp[1]).encode('utf-8')
            s = prx
        else:
            n = sp[0]
            s = sp[1]

        rp.append(Prop(s, n, *sp[2:]))


cdef _flatten_collapsible(object l, object rp, object excl, object anc, object acc):
    cdef int excluded, ineligible

    for sp in anc.all_non_exclusions:
        excluded = (anc.name, sp.name) in excl
        ineligible = sp.flags & Flag.InsideArray

        if excluded or ineligible:
            continue

        if sp.type is Type.DataTable:
            if sp.flags & Flag.Collapsible:
                _flatten_collapsible(l, rp, excl, l[sp.dt], acc)
            else:
                _flatten(l, rp, excl, l[sp.dt], [], prx=sp.src)
        else:
            acc.append(sp)
