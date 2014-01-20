

cpdef PacketEntitiesDecoder mk(object recv_tables)


cdef class PacketEntitiesDecoder(object):
    cdef public object recv_tables
    cdef public int class_bits
    cdef public object decoders

    cpdef decode(PacketEntitiesDecoder self, object stream, int is_delta, int count, object world)
    cdef _decode_diff(PacketEntitiesDecoder self, object stream, int index, object entities)
    cdef _decode_deletion_diffs(PacketEntitiesDecoder self, stream)
