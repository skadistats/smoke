

def enum(**enums):
    _enum = type('Enum', (), enums)
    _enum.tuples = enums
    return _enum
