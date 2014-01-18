

def mk(prop, array_prop_decoder):
    return ArrayDecoder(prop, array_prop_decoder)


class ArrayDecoder(object):
    def __init__(self, prop, array_prop_decoder):
        self.prop = prop

        shift, bits = prop.len, 0

        # there is probably a more concise way to do this
        while shift:
            shift >>= 1
            bits += 1

        self.bits = bits
        self.decoder = array_prop_decoder

    def decode(self, stream):
        count = stream.read_numeric_bits(self.bits)
        return [self.decoder.decode(stream) for _ in range(count)]
