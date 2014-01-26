# cython: profile=False

from smoke.protobuf import dota2_palm as pbd2


cdef dict TOP = {
    pbd2.DEM_FileHeader:        pbd2.CDemoFileHeader,
    pbd2.DEM_SignonPacket:      pbd2.CDemoPacket,
    pbd2.DEM_SendTables:        pbd2.CDemoSendTables,
    pbd2.DEM_StringTables:      pbd2.CDemoStringTables,
    pbd2.DEM_ClassInfo:         pbd2.CDemoClassInfo,
    pbd2.DEM_SyncTick:          pbd2.CDemoSyncTick,
    pbd2.DEM_FullPacket:        pbd2.CDemoFullPacket,
    pbd2.DEM_Packet:            pbd2.CDemoPacket,
    pbd2.DEM_Stop:              pbd2.CDemoStop,
    pbd2.DEM_FileInfo:          pbd2.CDemoFileInfo
}


cdef dict EMBED = {
    pbd2.svc_ServerInfo:        pbd2.CSVCMsg_ServerInfo,
    pbd2.net_Tick:              pbd2.CNETMsg_Tick,
    pbd2.net_SetConVar:         pbd2.CNETMsg_SetConVar,
    pbd2.svc_CreateStringTable: pbd2.CSVCMsg_CreateStringTable,
    pbd2.net_SignonState:       pbd2.CNETMsg_SignonState,
    pbd2.svc_SendTable:         pbd2.CSVCMsg_SendTable,
    pbd2.svc_ClassInfo:         pbd2.CSVCMsg_ClassInfo,
    pbd2.svc_VoiceInit:         pbd2.CSVCMsg_VoiceInit,
    pbd2.svc_GameEventList:     pbd2.CSVCMsg_GameEventList,
    pbd2.svc_SetView:           pbd2.CSVCMsg_SetView,
    pbd2.svc_PacketEntities:    pbd2.CSVCMsg_PacketEntities,
    pbd2.svc_VoiceData:         pbd2.CSVCMsg_VoiceData,
    pbd2.svc_GameEvent:         pbd2.CSVCMsg_GameEvent,
    pbd2.svc_UpdateStringTable: pbd2.CSVCMsg_UpdateStringTable,
    pbd2.svc_UserMessage:       pbd2.CSVCMsg_UserMessage,
    pbd2.svc_TempEntities:      pbd2.CSVCMsg_TempEntities,
    pbd2.svc_Sounds:            pbd2.CSVCMsg_Sounds,
}


cdef object mk_top(object peek, str message):
    return TOP[peek.kind](message)


cdef object mk_embed(object peek, str message):
    return EMBED[peek.kind](message)
