from smoke.util import enum


Game = enum(Entities     = 1 << 0, TempEntities = 1 << 1, Modifiers = 1 << 2,
            UserMessages = 1 << 3, GameEvents   = 1 << 4, Sounds    = 1 << 5,
            VoiceData    = 1 << 6, All          = 0xFF)
