from smoke.io.stream cimport entity


cpdef PacketEntitiesDecoder mk(object recv_tables)


cdef class PacketEntitiesDecoder(object):
    cdef public object recv_tables
    cdef public int class_bits
    cdef public dict decoders

    cpdef fetch_decoder(PacketEntitiesDecoder self, int cls)
    cpdef decode(PacketEntitiesDecoder self, entity.Stream stream, int is_delta, int count, object world)
    cdef _decode_diff(PacketEntitiesDecoder self, entity.Stream stream, int index, object entities)
    cdef _decode_deletion_diffs(PacketEntitiesDecoder self, entity.Stream stream)
