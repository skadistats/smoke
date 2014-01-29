# cython: profile=False


cpdef handle(object pb, rply_mtch.Match match):
    match.voice_data.append(pb)
