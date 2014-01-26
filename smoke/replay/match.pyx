# cython: profile=False

from smoke.model.dt cimport recv_table as mdl_dt_rcvtbl
from smoke.replay.decoder cimport packet_entities as rply_dcdr_pcktntts
from smoke.replay.decoder cimport temp_entities as rply_dcdr_tmpntts

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
        self._class_bits = None
        self._instance_baseline_cache = dict()
        self._packet_entities_decoder = None
        self._temp_entities_decoder = None

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
            if not self._class_bits:
                self._class_bits = len(self.recv_tables.by_cls).bit_length()

            return self._class_bits

    property packet_entities_decoder:
        def __get__(self):
            if not self._packet_entities_decoder:
                self._packet_entities_decoder = \
                    rply_dcdr_pcktntts.Decoder(self.recv_tables, self.class_bits)

            return self._packet_entities_decoder

    property temp_entities_decoder:
        def __get__(self):
            if not self._temp_entities_decoder:
                self._temp_entities_decoder = \
                    rply_dcdr_tmpntts.Decoder(self.packet_entities_decoder)

            return self._temp_entities_decoder

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
        self.temp_entities = None # TBD: what collection to use here?
        self.game_events = defaultdict(list)
        self.user_messages = defaultdict(list)
        self.sounds = None
        self.voice_data = list()
