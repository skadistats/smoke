from smoke.replay cimport match as rply_mtch


cdef handle(object pb, rply_mtch.Match match)

cdef void _handle_dem_fileheader(object pb, rply_mtch.Match match)
cdef void _handle_svc_serverinfo(object pb, rply_mtch.Match match)
cdef void _handle_net_tick(object pb, rply_mtch.Match match)
cdef void _handle_net_setconvar(object pb, rply_mtch.Match match)
cdef void _handle_svc_createstringtable(object pb, rply_mtch.Match match)
cdef void _handle_net_signonstate(object pb, rply_mtch.Match match)
cdef void _handle_svc_sendtable(object pb, rply_mtch.Match match)
cdef void _handle_dem_classinfo(object pb, rply_mtch.Match match)
cdef void _handle_svc_voiceinit(object pb, rply_mtch.Match match)
cdef void _handle_svc_gameeventlist(object pb, rply_mtch.Match match)
cdef void _handle_svc_setview(object pb, rply_mtch.Match match)
cdef void _handle_svc_packetentities(object pb, rply_mtch.Match match)
cdef void _handle_svc_gameevent(object pb, rply_mtch.Match match)
cdef void _handle_svc_usermessage(object pb, rply_mtch.Match match)
cdef void _handle_svc_updatestringtable(object pb, rply_mtch.Match match)
cdef void _handle_svc_tempentities(object pb, rply_mtch.Match match)
cdef void _handle_svc_sounds(object pb, rply_mtch.Match match)
cdef void _handle_svc_voicedata(object pb, rply_mtch.Match match)
cdef void _handle_dem_fileinfo(object pb, rply_mtch.Match match)
