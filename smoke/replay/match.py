from itertools import chain
from smoke.model.collection import recv_tables as mdl_cllctn_rcvtbls
from smoke.model.dt import recv_table as mdl_dt_rcvtbl
from smoke.model.dt.prop import Prop, Flag, Type


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

    def flatten_send_tables(self):
        recv_tables = dict()

        for dt, send_table in self.send_tables.items():
            if not send_table.needs_flattening:
                continue

            cls = self.class_info[dt]
            recv_props = self.flatten_send_table(send_table)
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

    def flatten_send_table(self, descendant):
        assert descendant.needs_flattening

        def _aggregate_exclusions(send_table):
            relations = send_table.all_relations
            fn = lambda sp: _aggregate_exclusions(self.send_tables[sp.dt])
            excl = map(fn, relations)
            return list(send_table.all_exclusions) + list(chain(*excl))

        exclusions = _aggregate_exclusions(descendant)
        recv_props = [] # shared state within recursion

        def _flatten(ancestor, accumulator=None, proxy=None):
            accumulator = accumulator or []

            _flatten_collapsible(ancestor, accumulator)

            for send_prop in accumulator:
                s, n, t, f, p, l, b, d, _l, h, ap = send_prop

                if proxy:
                    n = '{}.{}'.format(s, n).encode('utf-8')
                    s = proxy

                # note: recv_props accessible by closure
                recv_props.append(Prop(s, n, t, f, p, l, b, d, _l, h, ap))

        def _flatten_collapsible(ancestor, accumulator):
            for send_prop in ancestor.all_non_exclusions:
                excluded = (ancestor.name, send_prop.name) in exclusions
                ineligible = send_prop.flags & Flag.InsideArray

                if excluded or ineligible:
                    continue

                if send_prop.type is Type.DataTable:
                    target = self.send_tables[send_prop.dt]
                    if send_prop.flags & Flag.Collapsible:
                        _flatten_collapsible(target, accumulator)
                    else:
                        _flatten(target, [], proxy=send_prop.src)
                else:
                    accumulator.append(send_prop)

        _flatten(descendant) # recv_props is mutated by this process

        return recv_props
