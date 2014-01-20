from itertools import chain
from smoke.model.collection import recv_tables as mdl_cllctn_rcvtbls
from smoke.model.dt import recv_table as mdl_dt_rcvtbl
from smoke.model.dt.prop import Prop, Flag, Type
from smoke.replay import flattening
from smoke.replay.decoder import packet_entities as rply_dcdr_pcktntts


def mk():
    return Match()


class Match(object):
    def __init__(self):
        # prologue
        self.file_header = None
        self.signon_state = None
        self.server_info = None
        self.basis_string_tables = None
        self.send_tables = None
        self.class_info = None
        self.recv_tables = None
        self.con_vars = None
        self.voice_init = None
        self.game_event_descriptors = None
        self.view = None
        self._packet_entities_decoder = None

        # game
        self.tick = None
        self.entities = None
        self.modifiers = None
        self.temp_entities = None
        self.game_events = None
        self.user_messages = None
        self.sounds = None
        self.voice_data = None

        # epilogue
        self.file_info = None

    @property
    def packet_entities_decoder(self):
        if not self._packet_entities_decoder:
            self._packet_entities_decoder = \
                rply_dcdr_pcktntts.mk(self.recv_tables)

        return self._packet_entities_decoder

    def flatten_send_tables(self):
        recv_tables = dict()

        for dt, send_table in self.send_tables.items():
            if not send_table.needs_flattening:
                continue

            cls = self.class_info[dt]
            recv_props = flattening.flatten(send_table, self.send_tables)
            recv_tables[cls] = mdl_dt_rcvtbl.mk(dt, recv_props)

        self.recv_tables = mdl_cllctn_rcvtbls.mk(recv_tables)

    def check_sanity(self):
        assert self.file_header and self.signon_state and self.server_info \
            and self.basis_string_tables and self.send_tables and \
            self.class_info and self.recv_tables and self.con_vars and \
            self.voice_init and self.game_event_descriptors and self.view

    def reset_transient_state(self):
        self.temp_entities = None # TBD: what collection to use here?
        self.game_events = dict()
        self.user_messages = dict()
        self.sounds = list()
        self.voice_data = list()
