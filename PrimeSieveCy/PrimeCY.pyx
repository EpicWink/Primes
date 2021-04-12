# cython: language_level = 3

"""Cython prime sieve."""

import array
import types

cimport cython
from libc cimport math
from cpython cimport mem


cdef struct Sieve:
    unsigned long size
    unsigned char* rawbits


cdef void initialise_sieve(Sieve* sieve, unsigned long limit) except *:
    cdef size_t i

    sieve.size = limit
    sieve.rawbits = <unsigned char*> mem.PyMem_Malloc(
        (limit // 8 + 1) * sizeof(unsigned char)
    )
    if not sieve.rawbits:
        raise MemoryError("Unable to allocate sieve")
    for i in range((limit + 1) // 2):
        sieve.rawbits[i] = 85  # 01010101
    sieve.rawbits[0] |= 64  # set 2 as prime number


cdef void finalise_sieve(Sieve* sieve):
    mem.PyMem_Free(sieve.rawbits)


cdef unsigned char get_bit_c(Sieve* sieve, size_t index) nogil:
    if index % 2 == 0:
        return 0
    else:
        return sieve.rawbits[(index // 2) // 8] & (2 ** (7 - (index // 2) % 8))


def get_bit(object sieve_py, size_t index):
    cdef Sieve sieve
    cdef unsigned char result
    cdef unsigned long i

    sieve.size = sieve_py.size
    sieve.rawbits = <unsigned char*> mem.PyMem_Malloc(
        (sieve.size // 8 + 1) * sizeof(unsigned char)
    )
    if not sieve.rawbits:
        raise MemoryError("Unable to allocate sieve")
    for i in range(sieve.size):
        sieve.rawbits[i // 8] |= 2 ** (7 - i % 8) & sieve_py.rawbits[i]
    with nogil:
        result = get_bit_c(&sieve, index)
    mem.PyMem_Free(sieve.rawbits)
    if result:
        return True
    return False


cdef void clear_bit(Sieve* sieve, size_t index) nogil:
    if index % 2 == 0:
        # with gil:
        #     print("Can't set even bits")
        return
    sieve.rawbits[(index // 2) // 8] &= ~(2 ** (7 - (index // 2) % 8))


@cython.cdivision(True)
cdef void run(Sieve* sieve) nogil:
    cdef unsigned long factor
    cdef double q
    cdef unsigned long i, num

    factor = 3
    q = math.sqrt(sieve.size)

    while factor < q:
        for i in range(sieve.size - factor):
            num = i + factor
            if get_bit_c(sieve, num):
                factor = num
                break

        for i in range((sieve.size - factor * 3) // (factor * 2)):
            num = factor * (i * 2 + 3)
            clear_bit(sieve, num)

        factor += 2


def prime_sieve(unsigned long limit):
    cdef Sieve sieve
    cdef object rawbits
    cdef size_t i

    initialise_sieve(&sieve, limit)
    with nogil:
        run(&sieve)

    rawbits = array.array("B", b"\x00" * limit)
    for i in range(limit):
        rawbits[i] = get_bit_c(&sieve, i)
    finalise_sieve(&sieve)
    return types.SimpleNamespace(size=sieve.size, rawbits=rawbits)
