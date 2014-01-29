from smoke.io cimport plexer as io_plxr
from smoke.replay cimport match as rply_mtch


cdef dict DATA_DEPENDENCIES
cdef set ALL_EMBEDS
cdef set EMBED_WHITELIST


cdef set calc_deps(int parse)


cdef set mk_embed_blacklist(object deps)


cdef class Demo(object):
    cdef public int parse
    cdef public io_plxr.Plexer plexer
    cdef public rply_mtch.Match match

    cpdef bootstrap(Demo self)

    cpdef play(Demo self)

    cpdef finish(Demo self)
