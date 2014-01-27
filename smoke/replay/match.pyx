# cython: profile=False

from smoke.model.dt cimport recv_table as mdl_dt_rcvtbl

from collections import defaultdict
from smoke.model.collection import recv_tables as mdl_cllctn_rcvtbls
from smoke.replay import flattening


cdef class Match(object):
    def __init__(self):
        # prologue
        self.file_header = None
        self.signon_state = None
        self.server_info = None
        self.string_tables = None
        self.send_tables = None
        self.class_info = None
        self.recv_tables = None
        self.con_vars = None
        self.voice_init = None
        self.game_event_descriptors = None
        self.view = None
        self._class_bits = 0
        self._dt_decoders = None

        # data properties
        self.tick = None
        self.entities = None
        self.modifiers = None
        self.temp_entities = None
        self.game_events = None
        self.user_messages = None
        self.sounds = None
        self.voice_data = None

        # overview
        self.overview = None

    property class_bits:
        def __get__(self):
            if self._class_bits == 0:
                self._class_bits = len(self.recv_tables.by_cls).bit_length()

            return self._class_bits

    property dt_decoders:
        def __get__(self):
            if self._dt_decoders is None:
                self._dt_decoders = mdl_cllctn_dtdcdrs.Collection(self.recv_tables)

            return self._dt_decoders

    cdef flatten_send_tables(self):
        recv_tables = dict()

        for dt, send_table in self.send_tables.items():
            if not send_table.needs_flattening:
                continue

            cls = self.class_info[dt]
            recv_props = flattening.flatten(send_table, self.send_tables)
            recv_tables[cls] = mdl_dt_rcvtbl.RecvTable(dt, recv_props)

        self.recv_tables = mdl_cllctn_rcvtbls.Collection(recv_tables)

    cdef check_sanity(self):
        assert self.file_header and self.signon_state and self.server_info \
            and self.string_tables and self.send_tables and \
            self.class_info and self.recv_tables and self.con_vars and \
            self.voice_init and self.game_event_descriptors and self.view

    cdef reset_transient_state(self):
        self.temp_entities = defaultdict(list)
        self.game_events = defaultdict(list)
        self.user_messages = defaultdict(list)
        self.sounds = None
        self.voice_data = list()
