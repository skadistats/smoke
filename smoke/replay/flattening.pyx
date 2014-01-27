# cython: profile=False

from smoke.model.dt cimport prop as mdl_dt_prp

from itertools import chain


cpdef list flatten(object descendant, object lookup):
    assert descendant.needs_flattening

    cdef list excl = _aggregate_exclusions(lookup, descendant)
    cdef list rp = list() # shared state within recursion

    _flatten(lookup, rp, excl, descendant) # recv_props is mutated

    return rp


def _aggregate_exclusions(object l, object st):
    relations = st.all_relations
    excl = map(lambda sp: _aggregate_exclusions(l, l[sp.dt]), relations)
    return list(st.all_exclusions) + list(chain(*excl))


cdef _flatten(object l, list rp, list excl, object anc, list acc=None, object prx=None):
    cdef list _acc = acc or list()
    cdef unicode n, s

    _flatten_collapsible(l, rp, excl, anc, _acc)

    for sp in _acc:
        if prx:
            n = unicode('{}.{}'.format(sp.src, sp.name).encode('utf-8'))
            s = prx
        else:
            n = sp.src
            s = sp.name

        rp.append(mdl_dt_prp.Prop(s, n, sp.type, sp.flags, sp.pri, sp.len, sp.bits, sp.dt, sp.low, sp.high, sp.array_prop))


cdef _flatten_collapsible(object l, list rp, list excl, object anc, list acc):
    cdef int excluded, ineligible

    for sp in anc.all_non_exclusions:
        excluded = (anc.name, sp.name) in excl
        ineligible = sp.flags & mdl_dt_prp.INSIDEARRAY

        if excluded or ineligible:
            continue

        if sp.type is mdl_dt_prp.DATATABLE:
            if sp.flags & mdl_dt_prp.COLLAPSIBLE:
                _flatten_collapsible(l, rp, excl, l[sp.dt], acc)
            else:
                _flatten(l, rp, excl, l[sp.dt], list(), prx=sp.src)
        else:
            acc.append(sp)
