from smoke.replay import handler


HANDLERS = {
    pb_d.CDemoFileHeader: handler.handle_dem_fileheader,
}


class Ticker(object):
    def __init__(self, plexer, match):
        self.plexer = plexer
        self.match = match

    def __iter__(self):
        tick, collection = self.plexer.read_tick()

        match.tick = tick

        for _, pb in collection:
            HANDLERS[type(pb)](pb, self.match)

        yield self.match
