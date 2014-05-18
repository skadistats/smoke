# cython: profile=False

import warnings

from smoke.protobuf import dota2_palm as pbd2


cdef int DOTA_UM_ID_BASE = 64


cdef dict USER_MESSAGE_BY_KIND = {
    1: 'AchievementEvent',          2: 'CloseCaption',
    3: 'CloseCaptionDirect',        4: 'CurrentTimescale',
    5: 'DesiredTimescale',          6: 'Fade',
    7: 'GameTitle',                 8: 'Geiger',
    9: 'HintText',                 10: 'HudMsg',
   11: 'HudText',                  12: 'KeyHintText',
   13: 'MessageText',              14: 'RequestState',
   15: 'ResetHUD',                 16: 'Rumble',
   17: 'SayText',                  18: 'SayText2',
   19: 'SayTextChannel',           20: 'Shake',
   21: 'ShakeDir',                 22: 'StatsCrawlMsg',
   23: 'StatsSkipState',           24: 'TextMsg',
   25: 'Tilt',                     26: 'Train',
   27: 'VGUIMenu',                 28: 'VoiceMask',
   29: 'VoiceSubtitle',            30: 'SendAudio',
   63: 'MAX_BASE',                 64: 'AddUnitToSelection',
   65: 'AIDebugLine',              66: 'ChatEvent',
   67: 'CombatHeroPositions',      68: 'CombatLogData',
   70: 'CombatLogShowDeath',       71: 'CreateLinearProjectile',
   72: 'DestroyLinearProjectile',  73: 'DodgeTrackingProjectiles',
   74: 'GlobalLightColor',         75: 'GlobalLightDirection',
   76: 'InvalidCommand',           77: 'LocationPing',
   78: 'MapLine',                  79: 'MiniKillCamInfo',
   80: 'MinimapDebugPoint',        81: 'MinimapEvent',
   82: 'NevermoreRequiem',         83: 'OverheadEvent',
   84: 'SetNextAutobuyItem',       85: 'SharedCooldown',
   86: 'SpectatorPlayerClick',     87: 'TutorialTipInfo',
   88: 'UnitEvent',                89: 'ParticleManager',
   90: 'BotChat',                  91: 'HudError',
   92: 'ItemPurchased',            93: 'Ping',
   94: 'ItemFound',                95: 'CharacterSpeakConcept',
   96: 'SwapVerify',               97: 'WorldLine',
   98: 'TournamentDrop',           99: 'ItemAlert',
  100: 'HalloweenDrops',          101: 'ChatWheel',
  102: 'ReceivedXmasGift',        103: 'UpdateSharedContent',
  104: 'TutorialRequestExp',      105: 'TutorialPingMinimap',
  106: 'GamerulesStateChanged',   107: 'ShowSurvey',
  108: 'TutorialFade',            109: 'AddQuestLogEntry',
  110: 'SendStatPopup',           111: 'TutorialFinish',
  112: 'SendRoshanPopup',         113: 'SendGenericToolTip',
  114: 'SendFinalGold',           115: 'CustomMsg',
  116: 'CoachHUDPing',            117: 'ClientLoadGridNav',
  118: 'AbilityPing',             119: 'ShowGenericPopup',
  120: 'VoteStart',               121: 'VoteUpdate',
  122: 'VoteEnd',                 123: 'BoosterState',
  124: 'WillPurchaseAlert',       125: 'TutorialMinimapPosition',
  126: 'PlayerMMR',               127: 'AbilitySteal',
}


cpdef handle(object pb, rply_mtch.Match match):
    cdef:
        int kind = pb.msg_type
        str user_message = USER_MESSAGE_BY_KIND[kind]
        str cls
        str infix

    if kind == 106: # one-off?
        cls = 'CDOTA_UM_GamerulesStateChanged'
    else:
        infix = 'DOTA' if kind >= DOTA_UM_ID_BASE else ''
        cls = 'C' + infix + 'UserMsg_' + user_message

    try:
        pb = getattr(pbd2, cls)(pb.msg_data)
    except AttributeError, e:
        err = 'protobuf {0}: open issue at github.com/onethirtyfive/smoke'
        warnings.warn(err.format(cls))
        return

    match.user_messages[kind].append(pb)
