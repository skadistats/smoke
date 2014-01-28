from smoke.model cimport string_table as mdl_strngtbl
from smoke.model.collection cimport recv_tables as mdl_cllctn_rcvtbls
from smoke.model.collection cimport dt_decoders as mdl_cllctn_dtdcdrs
from smoke.model.collection cimport entities as mdl_cllctn_ntts


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
    cdef int _class_bits
    cdef mdl_cllctn_dtdcdrs.Collection _dt_decoders
    cdef mdl_strngtbl.StringTable _ibst

    cdef public mdl_cllctn_ntts.Collection entities
    cdef public object modifiers

    cdef public object tick
    cdef public object temp_entities
    cdef public object game_events
    cdef public object user_messages
    cdef public object sounds
    cdef public object voice_data

    cdef public object overview

    cdef flatten_send_tables(self)

    cdef check_sanity(self)

    cdef reset_transient_state(self)
