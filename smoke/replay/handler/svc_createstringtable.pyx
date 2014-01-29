# cython: profile=False

from smoke.model cimport string_table as mdl_strngtbl
from smoke.model.collection cimport string_tables as mdl_cllctn_strngtbl
from smoke.replay cimport match as rply_mtch
from smoke.replay.decoder cimport string_table as rply_dcdr_strngtbl


cpdef handle(object pb, rply_mtch.Match match):
    match.string_tables = match.string_tables or mdl_cllctn_strngtbl.Collection()

    cdef mdl_strngtbl.StringTable string_table
    cdef string_tables = <mdl_cllctn_strngtbl.Collection>match.string_tables

    index = len(string_tables.by_index)
    string_table = rply_dcdr_strngtbl.decode_and_create(pb)

    string_tables.by_index[index] = string_table
    string_tables.by_name[pb.name] = string_table

    match.string_tables = string_tables
