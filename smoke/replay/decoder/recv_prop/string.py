

def mk(prop):
    return StringDecoder(prop)


class StringDecoder(object):
    def __init__(self, prop):
        self.prop = prop

    def decode(self, stream):
        bytelength = stream.read_numeric_bits(9)
        return stream.read_string(bytelength)
