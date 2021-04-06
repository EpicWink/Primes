"""Cython prime sieve entry-point."""

import time

import PrimeCY

# Historical data for validating our results - the number of primes to be found
# under some limit, such as 168 primes under 1000
primeCounts = {
    10: 1,
    100: 25,
    1000: 168,
    10000: 1229,
    100000: 9592,
    1000000: 78498,
    10000000: 664579,
    100000000: 5761455
}


def count_primes(sieve):
    """Return the count of bits that are still set in the sieve.

    Assumes you've already called runSieve, of course!
    """

    return sum(1 for b in sieve.rawbits if b)


def validate_results(sieve):
    """Validate result.

    Look up our count of primes in the historical data (if we have it) to see
    if it matches.
    """

    # Check to see if this is an upper_limit we can the data, and (b) our count
    # matches. Since it will return
    if sieve.size in primeCounts:
        # false for an unknown upper_limit, can't assume false == bad
        return primeCounts[sieve.size] == count_primes(sieve)
    return False


def print_results(sieve, show_results, duration, passes):
    """Displays the primes found or just the total count."""

    # Since we auto-filter evens, we have to special case the number 2 which is
    # prime
    if show_results:
        print("2, ", end="")

    # count = 1
    # # Count (and optionally dump) the primes that were found below the limit
    # for num in range(3, sieve.size):
    #     if PrimeCY.get_bit(sieve, num):
    #         if show_results:
    #             print(f"{num}, ", end="")
    #         count += 1
    count = sum(sieve.rawbits)

    assert count == count_primes(sieve), (count, count_primes(sieve))
    valid = validate_results(sieve)
    print()
    print(
        f"Passes: {passes}, Time: {duration}, Avg: {duration / passes}, "
        f"Limit: {sieve.size}, Count: {count}, Valid: {valid}"
    )


def main():
    start = time.monotonic()  # record starting time
    passes = 0  # number of computations in fixed window of time

    sieve = None
    while time.monotonic() < start + 10.0:  # run until 10 seconds has elapsed
        sieve = PrimeCY.prime_sieve(1000000)  # compute primes under 1 million
        passes += 1  # count pass

    elapsed = time.monotonic() - start  # actual elapsed time
    if sieve:
        print_results(sieve, False, elapsed, passes)  # display outcome


if __name__ == "__main__":
    main()
