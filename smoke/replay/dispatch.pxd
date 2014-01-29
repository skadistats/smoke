from smoke.io cimport peek as io_pk
from smoke.replay cimport match as rply_mtch


cdef enum Top:
    DEM_CLASSINFO  = 5
    DEM_FILEHEADER = 1
    DEM_FILEINFO = 2


cdef enum Embed:
    NET_SETCONVAR = 6
    NET_SIGNONSTATE = 7
    NET_TICK = 4
    SVC_CLASSINFO = 10
    SVC_CREATESTRINGTABLE = 12
    SVC_GAMEEVENT = 25
    SVC_GAMEEVENTLIST = 30
    SVC_PACKETENTITIES = 26
    SVC_SENDTABLE = 9
    SVC_SERVERINFO = 8
    SVC_SETVIEW = 18
    SVC_SOUNDS = 17
    SVC_TEMPENTITIES = 27
    SVC_UPDATESTRINGTABLE = 13
    SVC_USERMESSAGE = 23
    SVC_VOICEDATA = 15
    SVC_VOICEINIT = 14


cpdef dispatch(io_pk.Peek peek, rply_mtch.Match match)
