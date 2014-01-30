# cython: profile=False

from smoke.io cimport peek as io_pk
from smoke.replay cimport match as rply_mtch
from smoke.replay.handler cimport dem_classinfo
from smoke.replay.handler cimport dem_fileheader
from smoke.replay.handler cimport dem_fileinfo
from smoke.replay.handler cimport dem_savegame
from smoke.replay.handler cimport dem_stringtables
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
        if kind == io_pk.DEM_ClassInfo:
            dem_classinfo.handle(pb, match)
        elif kind == io_pk.DEM_FileHeader:
            dem_fileheader.handle(pb, match)
        elif kind == io_pk.DEM_FileInfo:
            dem_fileinfo.handle(pb, match)
        elif kind == io_pk.DEM_SaveGame:
            dem_savegame.handle(pb, match)
        elif kind == io_pk.DEM_StringTables:
            dem_stringtables.handle(pb, match)
        else:
            raise NotImplementedError()
    else:
        if kind == io_pk.net_SetConVar:
            net_setconvar.handle(pb, match)
        elif kind == io_pk.net_SignonState:
            net_signonstate.handle(pb, match)
        elif kind == io_pk.net_Tick:
            net_tick.handle(pb, match)
        elif kind == io_pk.svc_ClassInfo:
            svc_classinfo.handle(pb, match)
        elif kind == io_pk.svc_CreateStringTable:
            svc_createstringtable.handle(pb, match)
        elif kind == io_pk.svc_GameEvent:
            svc_gameevent.handle(pb, match)
        elif kind == io_pk.svc_GameEventList:
            svc_gameeventlist.handle(pb, match)
        elif kind == io_pk.svc_PacketEntities:
            svc_packetentities.handle(pb, match)
        elif kind == io_pk.svc_SendTable:
            svc_sendtable.handle(pb, match)
        elif kind == io_pk.svc_ServerInfo:
            svc_serverinfo.handle(pb, match)
        elif kind == io_pk.svc_SetView:
            svc_setview.handle(pb, match)
        elif kind == io_pk.svc_Sounds:
            svc_sounds.handle(pb, match)
        elif kind == io_pk.svc_TempEntities:
            svc_tempentities.handle(pb, match)
        elif kind == io_pk.svc_UpdateStringTable:
            svc_updatestringtable.handle(pb, match)
        elif kind == io_pk.svc_UserMessage:
            svc_usermessage.handle(pb, match)
        elif kind == io_pk.svc_VoiceData:
            svc_voicedata.handle(pb, match)
        elif kind == io_pk.svc_VoiceInit:
            svc_voiceinit.handle(pb, match)
        else:
            raise NotImplementedError()
