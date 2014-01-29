# cython: profile=False

from smoke.replay cimport match as rply_mtch
from smoke.replay.handler cimport dem_classinfo
from smoke.replay.handler cimport dem_fileheader
from smoke.replay.handler cimport dem_fileinfo
from smoke.replay.handler cimport net_setconvar
from smoke.replay.handler cimport net_signonstate
from smoke.replay.handler cimport net_tick
from smoke.replay.handler cimport svc_classinfo
from smoke.replay.handler cimport svc_createstringtable
from smoke.replay.handler cimport svc_gameevent
from smoke.replay.handler cimport svc_gameeventlist
from smoke.replay.handler cimport svc_packetentities
from smoke.replay.handler cimport svc_sendtable
from smoke.replay.handler cimport svc_serverinfo
from smoke.replay.handler cimport svc_setview
from smoke.replay.handler cimport svc_sounds
from smoke.replay.handler cimport svc_tempentities
from smoke.replay.handler cimport svc_updatestringtable
from smoke.replay.handler cimport svc_usermessage
from smoke.replay.handler cimport svc_voicedata
from smoke.replay.handler cimport svc_voiceinit


cpdef dispatch(io_pk.Peek peek, rply_mtch.Match match):
    cdef bint embedded = peek.embedded
    cdef int kind = peek.kind
    cdef object pb = peek.mk()

    if not embedded:
        if kind == DEM_CLASSINFO:
            dem_classinfo.handle(pb, match)
        elif kind == DEM_FILEHEADER:
            dem_fileheader.handle(pb, match)
        elif kind == DEM_FILEINFO:
            dem_fileinfo.handle(pb, match)
        else:
            raise NotImplementedError()
    else:
        if kind == NET_SETCONVAR:
            net_setconvar.handle(pb, match)
        elif kind == NET_SIGNONSTATE:
            net_signonstate.handle(pb, match)
        elif kind == NET_TICK:
            net_tick.handle(pb, match)
        elif kind == SVC_CLASSINFO:
            svc_classinfo.handle(pb, match)
        elif kind == SVC_CREATESTRINGTABLE:
            svc_createstringtable.handle(pb, match)
        elif kind == SVC_GAMEEVENT:
            svc_gameevent.handle(pb, match)
        elif kind == SVC_GAMEEVENTLIST:
            svc_gameeventlist.handle(pb, match)
        elif kind == SVC_PACKETENTITIES:
            svc_packetentities.handle(pb, match)
        elif kind == SVC_SENDTABLE:
            svc_sendtable.handle(pb, match)
        elif kind == SVC_SERVERINFO:
            svc_serverinfo.handle(pb, match)
        elif kind == SVC_SETVIEW:
            svc_setview.handle(pb, match)
        elif kind == SVC_SOUNDS:
            svc_sounds.handle(pb, match)
        elif kind == SVC_TEMPENTITIES:
            svc_tempentities.handle(pb, match)
        elif kind == SVC_UPDATESTRINGTABLE:
            svc_updatestringtable.handle(pb, match)
        elif kind == SVC_USERMESSAGE:
            svc_usermessage.handle(pb, match)
        elif kind == SVC_VOICEDATA:
            svc_voicedata.handle(pb, match)
        elif kind == SVC_VOICEINIT:
            svc_voiceinit.handle(pb, match)
        else:
            raise NotImplementedError()
