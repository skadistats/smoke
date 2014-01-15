from protobuf.impl import demo_pb2 as pb_d
from protobuf.impl import netmessages_pb2 as pb_n
from protobuf.impl import networkbasetypes_pb2 as pb_nbt


TOP = {
    pb_d.DEM_FileHeader:        pb_d.CDemoFileHeader,
    pb_d.DEM_SignonPacket:      pb_d.CDemoPacket,
    pb_d.DEM_SendTables:        pb_d.CDemoSendTables,
    pb_d.DEM_StringTables:      pb_d.CDemoStringTables,
    pb_d.DEM_ClassInfo:         pb_d.CDemoClassInfo,
    pb_d.DEM_SyncTick:          pb_d.CDemoSyncTick,
    pb_d.DEM_FullPacket:        pb_d.CDemoFullPacket,
    pb_d.DEM_Packet:            pb_d.CDemoPacket,
    pb_d.DEM_Stop:              pb_d.CDemoStop,
    pb_d.DEM_FileInfo:          pb_d.CDemoFileInfo
}


EMBED = {
    pb_n.svc_ServerInfo:        pb_n.CSVCMsg_ServerInfo,
    pb_n.net_Tick:              pb_n.CNETMsg_Tick,
    pb_n.net_SetConVar:         pb_n.CNETMsg_SetConVar,
    pb_n.svc_CreateStringTable: pb_n.CSVCMsg_CreateStringTable,
    pb_n.net_SignonState:       pb_n.CNETMsg_SignonState,
    pb_n.svc_SendTable:         pb_n.CSVCMsg_SendTable,
    pb_n.svc_ClassInfo:         pb_n.CSVCMsg_ClassInfo,
    pb_n.svc_VoiceInit:         pb_n.CSVCMsg_VoiceInit,
    pb_n.svc_GameEventList:     pb_n.CSVCMsg_GameEventList,
    pb_n.svc_SetView:           pb_n.CSVCMsg_SetView,
    pb_n.svc_PacketEntities:    pb_n.CSVCMsg_PacketEntities,
    pb_n.svc_VoiceData:         pb_n.CSVCMsg_VoiceData,
    pb_n.svc_GameEvent:         pb_nbt.CSVCMsg_GameEvent,
    pb_n.svc_UpdateStringTable: pb_n.CSVCMsg_UpdateStringTable,
    pb_n.svc_UserMessage:       pb_nbt.CSVCMsg_UserMessage,
    pb_n.svc_TempEntities:      pb_n.CSVCMsg_TempEntities,
    pb_n.svc_Sounds:            pb_n.CSVCMsg_Sounds,
}


def mk_top(peek, message):
    pb = TOP[peek.kind]()
    pb.ParseFromString(message)
    return pb


def mk_embed(peek, message):
    pb = EMBED[peek.kind]()
    pb.ParseFromString(message)
    return pb
