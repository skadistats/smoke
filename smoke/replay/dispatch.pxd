from smoke.io cimport peek as io_pk
from smoke.replay cimport match as rply_mtch


cpdef dispatch(io_pk.Peek peek, rply_mtch.Match match)
