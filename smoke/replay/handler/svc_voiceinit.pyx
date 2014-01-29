# cython: profile=False


cpdef handle(object pb, rply_mtch.Match match):
    voice_init = {
        'quality': pb.quality,
        'codec': pb.codec,
        'version': pb.version
    }

    match.voice_init = voice_init
