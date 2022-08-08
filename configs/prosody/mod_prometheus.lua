-- Log statistics to Prometheus
--
-- Copyright (C) 2014 Daurnimator
-- Copyright (C) 2018 Emmanuel Gil Peyrot <linkmauve@linkmauve.fr>
-- Copyright (C) 2021 Jonas Schäfer <jonas@zombofant.net>
--
-- This module is MIT/X11 licensed.

module:set_global();

local tostring = tostring;
local t_insert = table.insert;
local t_concat = table.concat;
local socket = require "socket";
local statsman = require "core.statsmanager";
local get_stats = statsman.get_stats;
local get_metric_registry = statsman.get_metric_registry;
local collect = statsman.collect;

local function escape(text)
  return text:gsub("\\", "\\\\"):gsub("\"", "\\\""):gsub("\n", "\\n");
end

local function escape_name(name)
  return name:gsub("/", "__"):gsub("[^A-Za-z0-9_]", "_"):gsub("^[^A-Za-z_]", "_%1");
end

local function get_timestamp()
  -- Using LuaSocket for that because os.time() only has second precision.
  return math.floor(socket.gettime() * 1000);
end

local function repr_help(metric, docstring)
  docstring = docstring:gsub("\\", "\\\\"):gsub("\n", "\\n");
  return "# HELP "..escape_name(metric).." "..docstring.."\n";
end

local function repr_unit(metric, unit)
  if not unit then
    unit = ""
  else
    unit = unit:gsub("\\", "\\\\"):gsub("\n", "\\n");
  end
  return "# UNIT "..escape_name(metric).." "..unit.."\n";
end

-- local allowed_types = { counter = true, gauge = true, histogram = true, summary = true, untyped = true };
-- local allowed_types = { "counter", "gauge", "histogram", "summary", "untyped" };
local function repr_type(metric, type_)
  -- if not allowed_types:contains(type_) then
  -- 	return;
  -- end
  return "# TYPE "..escape_name(metric).." "..type_.."\n";
end

local function repr_label(key, value)
  return key.."=\""..escape(value).."\"";
end

local function repr_labels(labelkeys, labelvalues, extra_labels)
  local values = {}
  if labelkeys then
    for i, key in ipairs(labelkeys) do
      local value = labelvalues[i]
      t_insert(values, repr_label(escape_name(key), escape(value)));
    end
  end
  if extra_labels then
    for key, value in pairs(extra_labels) do
      t_insert(values, repr_label(escape_name(key), escape(value)));
    end
  end
  if #values == 0 then
    return "";
  end
  return "{"..t_concat(values, ",").."}";
end

local function repr_sample(metric, labelkeys, labelvalues, extra_labels, value)
  return escape_name(metric)..repr_labels(labelkeys, labelvalues, extra_labels).." "..string.format("%.17g", value).."\n";
end

local get_metrics;
if statsman.get_metric_registry then
  module:log("debug", "detected OpenMetrics statsmanager")
  -- Prosody 0.12+ with OpenMetrics
  function get_metrics(event)
    local response = event.response;
    response.headers.content_type = "application/openmetrics-text; version=0.0.4";

    if collect then
      -- Ensure to get up-to-date samples when running in manual mode
      collect()
    end

    local registry = get_metric_registry()
    if registry == nil then
      response.headers.content_type = "text/plain; charset=utf-8"
      response.status_code = 404
      return "No statistics provider configured\n"
    end
    local answer = {};
    for metric_family_name, metric_family in pairs(registry:get_metric_families()) do
      t_insert(answer, repr_help(metric_family_name, metric_family.description))
      t_insert(answer, repr_unit(metric_family_name, metric_family.unit))
      t_insert(answer, repr_type(metric_family_name, metric_family.type_))
      for labelset, metric in metric_family:iter_metrics() do
        for suffix, extra_labels, value in metric:iter_samples() do
          t_insert(answer, repr_sample(metric_family_name..suffix, metric_family.label_keys, labelset, extra_labels, value))
        end
      end
    end
    t_insert(answer, "# EOF\n")
    return t_concat(answer, "");
  end
else
  module:log("debug", "detected pre-OpenMetrics statsmanager")
  -- Pre-OpenMetrics

  local allowed_extras = { min = true, max = true, average = true };
  local function insert_extras(data, key, name, timestamp, extra)
    if not extra then
      return false;
    end
    local has_extra = false;
    for extra_name in pairs(allowed_extras) do
      if extra[extra_name] then
        local field = {
          value = extra[extra_name],
          labels = {
            ["type"] = name,
            field = extra_name,
          },
          typ = "gauge";
          timestamp = timestamp,
        };
        t_insert(data[key], field);
        has_extra = true;
      end
    end
    return has_extra;
  end

  local function parse_stats()
    local timestamp = tostring(get_timestamp());
    local data = {};
    local stats, changed_only, extras = get_stats();
    for stat, value in pairs(stats) do
      -- module:log("debug", "changed_stats[%q] = %s", stat, tostring(value));
      local extra = extras[stat];
      local host, sect, name, typ = stat:match("^/([^/]+)/([^/]+)/(.+):(%a+)$");
      if host == nil then
        sect, name, typ = stat:match("^([^.]+)%.(.+):(%a+)$");
      elseif host == "*" then
        host = nil;
      end
      if sect:find("^mod_measure_.") then
        sect = sect:sub(13);
      elseif sect:find("^mod_statistics_.") then
        sect = sect:sub(16);
      end

      local key = escape_name("prosody_"..sect);
      local field = {
        value = value,
        labels = { ["type"] = name},
        -- TODO: Use the other types where it makes sense.
        typ = (typ == "rate" and "counter" or "gauge"),
        timestamp = timestamp,
      };
      if host then
        field.labels.host = host;
      end
      if data[key] == nil then
        data[key] = {};
      end
      if not insert_extras(data, key, name, timestamp, extra) then
        t_insert(data[key], field);
      end
    end
    return data;
  end

  function get_metrics(event)
    local response = event.response;
    response.headers.content_type = "text/plain; version=0.0.4";
    if statsman.collect then
      statsman.collect()
    end

    local answer = {};
    for key, fields in pairs(parse_stats()) do
      t_insert(answer, repr_help(key, ""));
      t_insert(answer, repr_type(key, fields[1].typ));
      for _, field in pairs(fields) do
        t_insert(answer, repr_sample(key, nil, nil, field.labels, field.value, field.timestamp));
      end
    end
    return t_concat(answer, "");
  end
end

function module.add_host(module)
  module:depends "http";
  module:provides("http", {
    default_path = "metrics";
    route = {
      GET = get_metrics;
    };
  });
end
