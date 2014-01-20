from collections import namedtuple
from smoke.util import enum


Type = enum(
    Int       = 0, Float  = 1, Vector = 2,
    VectorXY  = 3, String = 4, Array  = 5,
    DataTable = 6, Int64  = 7)


Flag = enum(
    Unsigned              = 1 <<  0, Coord                   = 1 <<  1,
    NoScale               = 1 <<  2, RoundDown               = 1 <<  3,
    RoundUp               = 1 <<  4, Normal                  = 1 <<  5,
    Exclude               = 1 <<  6, XYZE                    = 1 <<  7,
    InsideArray           = 1 <<  8, ProxyAlways             = 1 <<  9,
    VectorElem            = 1 << 10, Collapsible             = 1 << 11,
    CoordMP               = 1 << 12, CoordMPLowPrecision     = 1 << 13,
    CoordMPIntegral       = 1 << 14, CellCoord               = 1 << 15,
    CellCoordLowPrecision = 1 << 16, CellCoordIntegral       = 1 << 17,
    ChangesOften          = 1 << 18, EncodedAgainstTickcount = 1 << 19)


Prop = namedtuple('Prop',
    'src, name, type, flags, pri, len, bits, dt, low, high, array_prop')
