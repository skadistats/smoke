# cython: profile=False

from smoke.io.stream cimport entity as io_strm_ntt
from smoke.model cimport string_table as mdl_strngtbl
from smoke.replay.decoder cimport string_table as rply_dcdr_strngtbl
from smoke.replay.decoder cimport dt as rply_dcdr_dt

from smoke.protobuf import dota2_palm as pbd2


cpdef handle(object pb, rply_mtch.Match match):
    cdef mdl_strngtbl.StringTable string_table = <mdl_strngtbl.StringTable>match.string_tables.by_index[pb.table_id]
    cdef io_strm_ntt.Stream stream
    cdef rply_dcdr_dt.Decoder dt_decoder
 
    update = rply_dcdr_strngtbl.decode_update(pb, string_table)

    for string in update:
        string_table.update(string)

    if string_table.name == 'ActiveModifiers':
        for string in update:
            _pb = pbd2.CDOTAModifierBuffTableEntry(string.value)

            if _pb.entry_type == pbd2.DOTA_MODIFIER_ENTRY_TYPE_ACTIVE:
                match.modifiers[_pb.parent][_pb.index] = _pb
            else:
                assert _pb.entry_type == pbd2.DOTA_MODIFIER_ENTRY_TYPE_REMOVED

                try:
                    for_parent = match.modifiers[_pb.parent]

                    try:
                        del for_parent[_pb.index]
                    except KeyError:
                        pass

                    if len(for_parent) == 0:
                        del match.modifiers[_pb.parent]
                except KeyError:
                    pass
