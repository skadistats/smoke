from collections import defaultdict
from smoke.model.collection import recv_tables as mdl_cllctn_rcvtbls
from smoke.model.dt import recv_table as mdl_dt_rcvtbl
from smoke.replay import flattening
from smoke.replay.decoder import packet_entities as rply_dcdr_pcktntts


cpdef Match mk():
    return Match()


cdef class Match(object):
    cdef public object file_header
    cdef public object signon_state
    cdef public object server_info
    cdef public object string_tables
    cdef public object send_tables
    cdef public object class_info
    cdef public object recv_tables
    cdef public object con_vars
    cdef public object voice_init
    cdef public object game_event_descriptors
    cdef public object view
    cdef public object _packet_entities_decoder
    cdef public object _instance_baseline_cache

    cdef public object tick
    cdef public object entities
    cdef public object modifiers
    cdef public object temp_entities
    cdef public object game_events
    cdef public object user_messages
    cdef public object sounds
    cdef public object voice_data

    cdef public object overview

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
        self._packet_entities_decoder = None
        self._instance_baseline_cache = dict()

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

    property packet_entities_decoder:
        def __get__(self):
            if not self._packet_entities_decoder:
                self._packet_entities_decoder = \
                    rply_dcdr_pcktntts.mk(self.recv_tables)

            return self._packet_entities_decoder

    cpdef flatten_send_tables(self):
        recv_tables = dict()

        for dt, send_table in self.send_tables.items():
            if not send_table.needs_flattening:
                continue

            cls = self.class_info[dt]
            recv_props = flattening.flatten(send_table, self.send_tables)
            recv_tables[cls] = mdl_dt_rcvtbl.mk(dt, recv_props)

        self.recv_tables = mdl_cllctn_rcvtbls.mk(recv_tables)

    cpdef check_sanity(self):
        assert self.file_header and self.signon_state and self.server_info \
            and self.string_tables and self.send_tables and \
            self.class_info and self.recv_tables and self.con_vars and \
            self.voice_init and self.game_event_descriptors and self.view

    cpdef reset_transient_state(self):
        self.temp_entities = None # TBD: what collection to use here?
        self.game_events = defaultdict(list)
        self.user_messages = defaultdict(list)
        self.sounds = None
        self.voice_data = list()
