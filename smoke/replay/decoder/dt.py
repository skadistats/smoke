from smoke.model.dt.prop import Prop
from smoke.replay.decoder import recv_prop as rply_dcdr_rcvprp


def mk(recv_table):
    return DTDecoder(recv_table)


class DTDecoder(object):
    @classmethod
    def mk_cached_decoder(cls, recv_prop):
        try:
            cls.cache
        except AttributeError:
            cls.cache = dict()

        if recv_prop not in cls.cache:
            cls.cache[recv_prop] = rply_dcdr_rcvprp.mk(recv_prop)

        return cls.cache[recv_prop]

    def __init__(self, recv_table):
        self.recv_table = recv_table
        self.by_index = []
        self.by_recv_prop = dict()

        for recv_prop in recv_table:
            recv_prop_decoder = DTDecoder.mk_cached_decoder(recv_prop)
            self.by_index.append(recv_prop_decoder)
            self.by_recv_prop[recv_prop] = recv_prop_decoder

    def __iter__(self):
        for recv_prop, recv_prop_decoder in self.by_recv_prop.items():
            yield recv_prop, recv_prop_decoder

        raise StopIteration()

    def decode(self, stream, prop_list):
        return dict([(i, self.by_index[i].decode(stream)) for i in prop_list])
