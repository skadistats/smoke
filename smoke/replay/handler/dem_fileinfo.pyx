# cython: profile=False


cpdef handle(object pb, rply_mtch.Match match):
    game_info = pb.game_info.dota

    players = list()
    for player_details in game_info.player_info:
        entry = {
            'hero_name': player_details.get('hero_name'),
            'player_name': player_details.get('player_name'),
            'is_fake_client': player_details.get('is_fake_client'),
            'steam_id': player_details.get('steamid'),
            'game_team': player_details.get('game_team')
        }
        players.append(entry)

    picks_bans = list()
    for hero_selection_details in game_info.picks_bans:
        entry = {
            'is_pick': hero_selection_details.get('is_pick'),
            'team': hero_selection_details.get('team'),
            'hero_id': hero_selection_details.get('hero_id')
        }
        picks_bans.append(entry)

    overview = {
        'playback': {
            'time': pb.get('playback_time'),
            'ticks': pb.get('playback_ticks'),
            'frames': pb.get('playback_frames')
        },
        'game': {
            'players': players,
            'hero_selections': picks_bans,
            'match_id': game_info.get('match_id'),
            'game_mode': game_info.get('game_mode'),
            'game_winner': game_info.get('game_winner'),
            'league_id': game_info.get('leagueid'),
            'radiant_team': {
                'id': game_info.get('radiant_team_id'),
                'tag': game_info.get('radiant_team_tag')
            },
            'dire_team': {
                'id': game_info.get('dire_team_id'),
                'tag': game_info.get('dire_team_tag')
            },
            'end_time': game_info.get('end_time')
        }
    }

    match.overview = overview
