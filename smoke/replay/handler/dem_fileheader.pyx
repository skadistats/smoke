# cython: profile=False


cpdef handle(object pb, rply_mtch.Match match):
    file_header = {
        'demo_file_stamp': pb.get('demo_file_stamp'),
        'network_protocol': pb.get('network_protocol'),
        'server_name': pb.get('server_name'),
        'client_name': pb.get('client_name'),
        'map_name': pb.get('map_name'),
        'game_directory': pb.get('game_directory'),
        'fullpackets_version': pb.get('fullpackets_version'),
        'allow_clientside_entities': pb.get('allow_clientside_entities'),
        'allow_clientside_particles': pb.get('allow_clientside_particles')
    }

    match.file_header = file_header
