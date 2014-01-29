# cython: profile=False

from smoke.model.dt cimport send_table as mdl_dt_sndtbl
from smoke.model.dt cimport prop as mdl_dt_prp


cpdef handle(object pb, rply_mtch.Match match):
    send_tables = match.send_tables or dict()
    send_props = list()

    for sp in pb.props:
        # for send props of type ARRAY, the previous property stored is
        # the "template" for each of the items in the array.
        array_prop = send_props[-1] if sp.type is mdl_dt_prp.ARRAY else None

        num_elements = sp.get('num_elements', default=0)
        num_bits = sp.get('num_bits', default=0)
        dt_name = sp.get('dt_name', default=u'')
        low_value = sp.get('low_value', default=0.0)
        high_value = sp.get('high_value', default=0.0)

        send_prop = mdl_dt_prp.Prop(
            pb.net_table_name,
            sp.var_name, sp.type, sp.flags, sp.priority, num_elements,
            num_bits, dt_name, low_value, high_value, array_prop)

        send_props.append(send_prop)

    needs_decoder = pb.get('needs_decoder', default=False)

    try:
        send_tables[pb.net_table_name] = \
            mdl_dt_sndtbl.SendTable(pb.get('net_table_name'), send_props, needs_decoder)
    except Exception, e:
        assert pb.is_end

    match.send_tables = send_tables
