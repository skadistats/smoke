# cython: profile=False


cdef class Collection(object):
    def __init__(self, recv_table_by_cls):
        cdef dict by_cls = recv_table_by_cls
        cdef dict by_dt = dict()

        for recv_table in recv_table_by_cls.values():
            by_dt[recv_table.dt] = recv_table

        self.by_cls = by_cls
        self.by_dt = by_dt
