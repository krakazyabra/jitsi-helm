module:set_global();

local measure = require"core.statsmanager".measure;

local valid_shows = {
    available = true,
    chat = true,
    away = true,
    dnd = true,
    xa = true,
    unavailable = true,
}

local counters = {
    available = measure("amount", "client_presence.available"),
    chat = measure("amount", "client_presence.chat"),
    away = measure("amount", "client_presence.away"),
    dnd = measure("amount", "client_presence.dnd"),
    xa = measure("amount", "client_presence.xa"),
    unavailable = measure("amount", "client_presence.unavailable"),
    invalid = measure("amount", "client_presence.invalid");
};

module:hook("stats-update", function ()
    local buckets = {
        available = 0,
        chat = 0,
        away = 0,
        dnd = 0,
        xa = 0,
        unavailable = 0,
        invalid = 0,
    };
    for _, session in pairs(full_sessions) do
        local status = "unavailable";
        if session.presence then
            status = session.presence:get_child_text("show") or "available";
        end
        if valid_shows[status] ~= nil then
            buckets[status] = buckets[status] + 1;
        else
            buckets.invalid = buckets.invalid + 1;
        end
    end
    for bucket, count in pairs(buckets) do
        counters[bucket](count)
    end
end)
