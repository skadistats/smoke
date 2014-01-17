from collections import namedtuple


def mk():
    return GameEventDescriptorsCollection()


GameEventDescriptor = namedtuple('GameEvent', 'id, name, keys')


class GameEventDescriptorsCollection(object):
    def __init__(self):
        self.by_eventid = dict()
        self.by_name = dict()
