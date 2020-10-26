module:set_global()

local filters = require"util.filters";

local stanza_kinds = { message = true, presence = true, iq = true };

local function rate(measures, dir)
    return function (stanza, session)
        measures[dir]();
        measures[dir .. "_" .. session.type]();
        if stanza.attr and not stanza.attr.xmlns and stanza_kinds[stanza.name] then
            measures[dir .. "_" .. session.type .. "_" .. stanza.name]();
        end
        return stanza;
    end
end

local measures = setmetatable({}, {
    __index = function (t, name)
        local m = module:measure(name, "rate");
        t[name] = m;
        return m;
    end
});

local function measure_stanza_counts(session)
    filters.add_filter(session, "stanzas/in",  rate(measures, "incoming"));
    filters.add_filter(session, "stanzas/out", rate(measures, "outgoing"));
end

filters.add_filter_hook(measure_stanza_counts);
