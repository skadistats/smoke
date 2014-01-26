from smoke.replay.decoder cimport packet_entities as rply_dcdr_pcktntts


cdef class Decoder(object):
    cdef int class_bits
    cdef rply_dcdr_pcktntts.Decoder packet_entities_decoder

    cdef object decode(Decoder self, object pb)
