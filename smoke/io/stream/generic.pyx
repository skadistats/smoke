# cython: profile=False

from libc cimport stdlib
from libc.stdint cimport int64_t, uint32_t, uint64_t, uint8_t
from cpython cimport array


cdef extern from "arpa/inet.h":
    uint32_t ntohl(uint32_t)


cpdef Stream mk(str data):
    return Stream(data)


cdef int WORD_BYTES = 4
cdef int WORD_BITS = WORD_BYTES * 8


cdef class Stream(object):
    def __init__(self, data):
        self.pos = 0

        remainder = len(data) % 4
        if remainder:
            data = data + '\0' * (4 - remainder)

        self._init_data(array.array('I', data))

    cdef int _init_data(Stream self, array.array[unsigned int] ary) except -1:
        cdef int lenwords = len(ary)
        cdef uint32_t *words = <uint32_t*>stdlib.malloc(lenwords * sizeof(uint32_t))

        if words is NULL:
          raise MemoryError()

        cdef int i = 0
        cdef uint32_t be
        for i in range(lenwords):
            be = ntohl(<uint32_t>ary[i])
            words[i] = (((be & 0xFF) << 24)  | ((be & 0xFF00) << 8) |
                        ((be >> 8) & 0xFF00) |  (be >> 24))

        self.lenwords = lenwords
        self.words = words

    cdef int _dealloc(Stream self):
        if self.words != NULL:
            stdlib.free(self.words)

    def __dealloc__(self):
        self._dealloc()

    cdef int read_numeric_bits(self, int n):
        cdef uint32_t a, b
        a = self.words[self.pos / 32]
        b = self.words[(self.pos + n - 1) / 32]

        cdef uint32_t read
        read = self.pos & 31

        a = a >> read
        b = b << (32 - read)

        # cast up to 64 because 1 << 32 will be 0 otherwise
        cdef uint32_t mask, ret
        mask = <uint32_t>((<uint64_t>1 << n) - 1)
        ret = (a | b) & mask

        self.pos += n

        return ret

    cdef bytes read_bits(Stream self, int bitlength):
        cdef object data = bytearray()
        cdef int i, remainder

        i = 0
        remainder = bitlength

        while remainder > 7:
            data.append(<unsigned char>self.read_numeric_bits(8))
            remainder -= 8
            i += 1

        if remainder:
            data.append(<unsigned char>self.read_numeric_bits(remainder))
            i += 1

        return bytes(data)

    cdef bytes read_string(Stream self, int bytelength):
        cdef int bitlength = bytelength * 8
        cdef object data = bytearray()
        cdef int i
        cdef unsigned char c

        i = 0
        remainder = bitlength

        while remainder > 7:
            c = <unsigned char>self.read_numeric_bits(8)
            if c == 0:
                break
            data.append(c)
            remainder -= 8
            i += 1

        return bytes(data)

    cdef int read_varint(Stream self):
        cdef uint64_t run, value
        run = value = 0

        cdef uint64_t bits
        while True:
            bits = self.read_numeric_bits(8)
            value |= (bits & 0x7f) << run
            run += 7

            if not (bits >> 7) or run == 35:
                break

        return value
