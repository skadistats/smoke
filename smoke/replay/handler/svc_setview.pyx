# cython: profile=False


cpdef handle(object pb, rply_mtch.Match match):
    match.view = { 'entity_index': pb.entity_index }
