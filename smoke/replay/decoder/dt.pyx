# cython: profile=False

from smoke.io.stream cimport generic
from smoke.replay.decoder.recv_prop cimport factory as dcdr_fctry

from smoke.model.dt.const import Prop


cpdef DTDecoder mk(object recv_table):
    return DTDecoder(recv_table)


cdef class DTDecoder(object):
    def __init__(DTDecoder self, object recv_table):
        self.recv_table = recv_table
        self.by_index = list()
        self.by_recv_prop = dict()
        self.cache = dict()

        for recv_prop in recv_table:
            if recv_prop not in self.cache:
                self.cache[recv_prop] = dcdr_fctry.mk(recv_prop)
            recv_prop_decoder = self.cache[recv_prop]

            self.by_index.append(recv_prop_decoder)
            self.by_recv_prop[recv_prop] = recv_prop_decoder

    def __iter__(DTDecoder self):
        for recv_prop, recv_prop_decoder in self.by_recv_prop.items():
            yield recv_prop, recv_prop_decoder

        raise StopIteration()

    cpdef dict decode(DTDecoder self, generic.Stream stream, list prop_list):
        cdef dict attrs = dict()

        for i in prop_list:
            attrs[i] = self.by_index[i].decode(stream)

        return attrs
