# cython: profile=False

from smoke.io.stream cimport entity as io_strm_ntt
from smoke.replay.decoder cimport dt as rply_dcdr_dt
from smoke.replay.decoder cimport packet_entities as rply_dcdr_pcktntts

from collections import defaultdict
from smoke.model.const import Entity, PVS


cdef class Decoder(object):
    def __init__(Decoder self, rply_dcdr_pcktntts.Decoder packet_entities_decoder):
        self.class_bits = packet_entities_decoder.class_bits
        self.packet_entities_decoder = packet_entities_decoder

    cdef object decode(Decoder self, object pb):
        cdef io_strm_ntt.Stream stream = io_strm_ntt.Stream(pb.entity_data)
        cdef int num_entries = pb.num_entries
        cdef object temp_entities = defaultdict(list)
        cdef int i, cls, mystery, new_cls
        cdef rply_dcdr_dt.Decoder decoder
        cdef list prop_list
        cdef dict state

        i = 0

        while i < num_entries:
            mystery = stream.read_numeric_bits(1) # always 0?
            new_cls = stream.read_numeric_bits(1)

            if new_cls:
                cls = stream.read_numeric_bits(self.class_bits) - 1

            decoder = self.packet_entities_decoder.fetch_decoder(cls)
            prop_list = stream.read_entity_prop_list()
            state = decoder.decode(stream, prop_list)

            temp_entities[cls].append(Entity(0, 0, PVS.Enter, state))

            i += 1

        return temp_entities
