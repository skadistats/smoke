

def mk(*args):
    return RecvTablesCollection(*args)


cdef class RecvTablesCollection(object):
    cdef public object by_cls
    cdef public object by_dt

    def __init__(self, recv_table_by_cls):
        cdef object by_cls = recv_table_by_cls
        cdef object by_dt = dict()

        for recv_table in recv_table_by_cls.values():
            by_dt[recv_table.dt] = recv_table

        self.by_cls = by_cls
        self.by_dt = by_dt
