import itertools

from smoke.model.dt.prop import Flag, Type


class SendTable(object):
    def __init__(self, name, send_props, needs_flattening):
        self.name = name
        self.send_props = send_props
        self.needs_flattening = needs_flattening

    @property
    def baseclass(self):
        gen = (sp.dt for sp in self.send_props if sp.name is 'baseclass')
        return next(gen, None)

    @property
    def all_exclusions(self):
        exclusions = (sp for sp in self.send_props if sp.flags & Flag.Exclude)
        return itertools.imap(lambda sp: (sp.dt, sp.name), exclusions)

    @property
    def all_non_exclusions(self):
        return (sp for sp in self.send_props if sp.flags ^ Flag.Exclude)

    @property
    def all_relations(self):
        non_exclusions = self.all_non_exclusions
        return (sp for sp in non_exclusions if sp.type is Type.DataTable)
