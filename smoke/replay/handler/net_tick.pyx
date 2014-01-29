# cython: profile=False


cpdef handle(object pb, rply_mtch.Match match):
    match.tick = pb.tick
    match.reset_transient_state()
