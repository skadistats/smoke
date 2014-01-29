# cython: profile=False

from smoke.io.stream cimport entity as io_strm_ntt
from smoke.model cimport entity as mdl_ntt
from smoke.model cimport string_table as mdl_strngtbl
from smoke.model.collection cimport dt_decoders as mdl_cllctn_dtdcdrs
from smoke.model.collection cimport entities as mdl_cllctn_ntts


cpdef handle(object pb, rply_mtch.Match match):
    cdef:
        mdl_strngtbl.StringTable ibst
        mdl_cllctn_dtdcdrs.Collection dt_decoders
        io_strm_ntt.Stream baseline_stream

        io_strm_ntt.Stream stream = io_strm_ntt.Stream(pb.entity_data)

        mdl_cllctn_ntts.Collection entities = match.entities
        mdl_ntt.Entity entity
        mdl_ntt.State state
        mdl_ntt.State patch
        int index = -1
        int updated_entries = pb.updated_entries
        int i
        int cls
        list prop_list

    for i in range(updated_entries):
        index = stream.read_entity_index(index)
        pvs = stream.read_entity_pvs()

        if pvs == mdl_ntt.PRESERVE:
            entity = entities.get(index)
            prop_list = stream.read_entity_prop_list()
            dt_decoders = <mdl_cllctn_dtdcdrs.Collection>match.dt_decoders
            decoder = dt_decoders.get(entity.cls)
            entity.state.merge(decoder.decode(stream, prop_list))
        elif pvs == mdl_ntt.ENTER:
            cls = stream.read_numeric_bits(match.class_bits)
            serial = stream.read_numeric_bits(10)
            prop_list = stream.read_entity_prop_list()
            dt_decoders = <mdl_cllctn_dtdcdrs.Collection>match.dt_decoders
            decoder = dt_decoders.get(cls)
            ibst = <mdl_strngtbl.StringTable>match.ibst
            baseline = ibst.by_name[str(cls)]
            baseline_stream = io_strm_ntt.Stream(baseline.value)
            state = decoder.decode_baseline(baseline_stream)
            patch = decoder.decode(stream, prop_list)
            state.merge(patch)
            entity = mdl_ntt.Entity(pvs, index, serial, cls, state)
            entities.put(index, entity)
        elif pvs == mdl_ntt.DELETE:
            entities.delete(index)
        elif pvs == mdl_ntt.LEAVE:
            entity = entities.get(index)
            entity.pvs = pvs

    if pb.is_delta:
        while stream.read_numeric_bits(1):
            index = stream.read_numeric_bits(11) # max is 2^11-1, or 2047
            try:
                entities.delete(index)
            except ValueError:
                pass

    entities.invalidate_views()
