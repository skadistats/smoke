# cython: profile=False

from libc cimport stdlib
from libc.stdint cimport int64_t, uint32_t, uint64_t, uint8_t
from cpython cimport array


cdef extern from "arpa/inet.h":
    uint32_t ntohl(uint32_t)


cdef int WORD_BYTES = 4
cdef int WORD_BITS = WORD_BYTES * 8


cdef class Stream(object):
    def __cinit__(self, str data):
        cdef int remainder = len(data) % 4
        if remainder:
            data = data + '\0' * (4 - remainder)

        ary = array.array('I', data)

        self.words = <uint32_t*>stdlib.malloc(len(ary) * sizeof(uint32_t))
        self.pos = 0

        if self.words is NULL:
          raise MemoryError()

        cdef int i
        cdef uint32_t be
        for i in range(len(ary)):
            be = ntohl(<uint32_t>ary[i])
            self.words[i] = (((be & 0xFF) <<     24) | ((be & 0xFF00) << 8) |
                             ((be >> 8)    & 0xFF00) |  (be >> 24))

    def __dealloc__(self):
        if self.words != NULL:
            stdlib.free(self.words)

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

    cdef str read_bits(Stream self, int bitlength):
        cdef bytearray data = bytearray()
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

        return str(data)

    cdef str read_string(Stream self, int bytelength):
        cdef bytearray data = bytearray()
        cdef int i = 0
        cdef unsigned char c
        cdef int remainder = bytelength * 8

        while remainder > 7:
            c = <unsigned char>self.read_numeric_bits(8)
            if c == 0:
                break
            data.append(c)
            remainder -= 8
            i += 1

        return str(data)

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
