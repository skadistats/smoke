import math

from smoke.replay.decoder.recv_prop import float as rply_dcdr_flt


def mk(prop):
    return VectorXYDecoder(prop)


class VectorXYDecoder(object):
    def __init__(self, prop):
        self.prop = prop
        self.decoder = rply_dcdr_flt.mk(prop)

    def decode(self, stream):
        x = self.decoder.decode(stream)
        y = self.decoder.decode(stream)

        return x, y
