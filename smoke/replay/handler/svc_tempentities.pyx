# cython: profile=False

from smoke.io.stream cimport entity as io_strm_ntt
from smoke.model cimport entity as mdl_ntt
from smoke.model.collection cimport dt_decoders as mdl_cllctn_dtdcdrs

from collections import defaultdict


cpdef handle(object pb, rply_mtch.Match match):
    cdef mdl_cllctn_dtdcdrs.Collection dt_decoders = \
        <mdl_cllctn_dtdcdrs.Collection>match.dt_decoders

    cdef io_strm_ntt.Stream stream = io_strm_ntt.Stream(pb.entity_data)
    cdef object temp_entities = defaultdict(list)
    cdef int i, cls, mystery, new_cls
    cdef list prop_list
    cdef mdl_ntt.State state

    for i in range(pb.num_entries):
        mystery = stream.read_numeric_bits(1) # always 0?
        new_cls = stream.read_numeric_bits(1)

        if new_cls:
            cls = stream.read_numeric_bits(match.class_bits) - 1

        prop_list = stream.read_entity_prop_list()
        state = dt_decoders.get(cls).decode(stream, prop_list)

        temp_entities[cls].append(mdl_ntt.Entity(mdl_ntt.ENTER, 0, 0, 0, state))

    match.temp_entities = temp_entities
