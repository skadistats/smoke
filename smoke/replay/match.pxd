from smoke.model.collection cimport recv_tables as mdl_cllctn_rcvtbls
from smoke.replay.decoder cimport packet_entities as rply_dcdr_pcktntts
from smoke.replay.decoder cimport temp_entities as rply_dcdr_tmpntts


cdef class Match(object):
    cdef public object file_header
    cdef public object signon_state
    cdef public object server_info
    cdef public object string_tables
    cdef public object send_tables
    cdef public object class_info
    cdef public mdl_cllctn_rcvtbls.Collection recv_tables
    cdef public object con_vars
    cdef public object voice_init
    cdef public object game_event_descriptors
    cdef public object view
    cdef public object _class_bits
    cdef public object _instance_baseline_cache
    cdef public rply_dcdr_pcktntts.Decoder _packet_entities_decoder
    cdef public rply_dcdr_tmpntts.Decoder _temp_entities_decoder

    cdef public object tick
    cdef public object entities
    cdef public object modifiers
    cdef public object temp_entities
    cdef public object game_events
    cdef public object user_messages
    cdef public object sounds
    cdef public object voice_data

    cdef public object overview

    cdef flatten_send_tables(self)

    cdef check_sanity(self)

    cdef reset_transient_state(self)
