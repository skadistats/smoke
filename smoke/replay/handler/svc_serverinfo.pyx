# cython: profile=False


cpdef handle(object pb, rply_mtch.Match match):
    server_info = {
        'server_count': pb.get('server_count'),
        'is_dedicated': pb.get('is_dedicated'),
        'is_hltv': pb.get('is_hltv'),
        'is_replay': pb.get('is_replay'),
        'c_os': pb.get('c_os'),
        'map_crc': pb.get('map_crc'),
        'client_crc': pb.get('client_crc'),
        'string_table_crc': pb.get('string_table_crc'),
        'max_clients': pb.get('max_clients'),
        'max_classes': pb.get('max_classes'),
        'player_slot': pb.get('player_slot'),
        'tick_interval': pb.get('tick_interval'),
        'game_dir': pb.get('game_dir'),
        'map_name': pb.get('map_name'),
        'sky_name': pb.get('sky_name'),
        'host_name': pb.get('host_name')
    }

    match.server_info = server_info
