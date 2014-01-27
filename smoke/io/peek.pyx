# cython: profile=False

from smoke.protobuf import dota2_palm as pbd2


cdef class Peek(object):
    def __cinit__(Peek self, bint compressed, bint embedded, int kind, int tick, int size, str message):
        self.compressed = compressed
        self.embedded = embedded
        self.kind = kind
        self.tick = tick
        self.size = size
        self.message = message

    cdef object mk(Peek self):
        if self.embedded:
            return self._mk_embed()

        return self._mk_top()

    cdef object _mk_top(Peek self):
        cdef object value = None

        if self.kind == DEM_FileHeader:
            value = pbd2.CDemoFileHeader(self.message)
        elif self.kind == DEM_SignonPacket:
            value = pbd2.CDemoPacket(self.message)
        elif self.kind == DEM_SendTables:
            value = pbd2.CDemoSendTables(self.message)
        elif self.kind == DEM_FileHeader:
            value = pbd2.CDemoStringTables(self.message)
        elif self.kind == DEM_ClassInfo:
            value = pbd2.CDemoClassInfo(self.message)
        elif self.kind == DEM_SyncTick:
            value = pbd2.CDemoSyncTick(self.message)
        elif self.kind == DEM_FullPacket:
            value = pbd2.CDemoFullPacket(self.message)
        elif self.kind == DEM_Packet:
            value = pbd2.CDemoPacket(self.message)
        elif self.kind == DEM_Stop:
            value = pbd2.CDemoStop(self.message)
        elif self.kind == DEM_FileInfo:
            value = pbd2.CDemoFileInfo(self.message)

        assert value is not None

        return value

    cdef object _mk_embed(Peek self):
        cdef object value = None

        if self.kind == svc_ServerInfo:
            value = pbd2.CSVCMsg_ServerInfo(self.message)
        elif self.kind == net_Tick:
            value = pbd2.CNETMsg_Tick(self.message)
        elif self.kind == net_SetConVar:
            value = pbd2.CNETMsg_SetConVar(self.message)
        elif self.kind == svc_CreateStringTable:
            value = pbd2.CSVCMsg_CreateStringTable(self.message)
        elif self.kind == net_SignonState:
            value = pbd2.CNETMsg_SignonState(self.message)
        elif self.kind == svc_SendTable:
            value = pbd2.CSVCMsg_SendTable(self.message)
        elif self.kind == svc_ClassInfo:
            value = pbd2.CSVCMsg_ClassInfo(self.message)
        elif self.kind == svc_VoiceInit:
            value = pbd2.CSVCMsg_VoiceInit(self.message)
        elif self.kind == svc_GameEventList:
            value = pbd2.CSVCMsg_GameEventList(self.message)
        elif self.kind == svc_SetView:
            value = pbd2.CSVCMsg_SetView(self.message)
        elif self.kind == svc_PacketEntities:
            value = pbd2.CSVCMsg_PacketEntities(self.message)
        elif self.kind == svc_VoiceData:
            value = pbd2.CSVCMsg_VoiceData(self.message)
        elif self.kind == svc_GameEvent:
            value = pbd2.CSVCMsg_GameEvent(self.message)
        elif self.kind == svc_UpdateStringTable:
            value = pbd2.CSVCMsg_UpdateStringTable(self.message)
        elif self.kind == svc_UserMessage:
            value = pbd2.CSVCMsg_UserMessage(self.message)
        elif self.kind == svc_TempEntities:
            value = pbd2.CSVCMsg_TempEntities(self.message)
        elif self.kind == svc_Sounds:
            value = pbd2.CSVCMsg_Sounds(self.message)

        assert value is not None

        return value
