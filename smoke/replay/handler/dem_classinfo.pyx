# cython: profile=False

from smoke.replay cimport match as rply_mtch


cpdef handle(object pb, rply_mtch.Match match):
    match.class_info = {i.table_name:int(i.class_id) for i in pb.classes}
