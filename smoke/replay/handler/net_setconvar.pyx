# cython: profile=False


cpdef handle(object pb, rply_mtch.Match match):
    con_vars = match.con_vars or dict()

    for cvar in pb.convars.cvars:
        name, value = cvar.name, cvar.value
        con_vars[name] = value

    match.con_vars = con_vars
