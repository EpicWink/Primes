# Cython implementation
Cython is an extension language for the Python runtime, and is a superset of
the Python language. Simply, it compiles down to C (or C++), which can then be
compiled and used by Python modules.

## Getting set-up
You'll need
* Python 3
* Cython - install with `pip install cython`

### Building
```shell
cythonize -i PrimeCY.pyx
```

## Running
```shell
python main.py
```
