-- lua filter for constructing metadata dynamically from YAML input
-- sources, using database-like queries.
-- Copyright (C) 2019 John MacFarlane, released under MIT license
--
-- Example of input:
-- ---
-- papers:
-- - select: articles
--   from: articles.yaml
--   where: 'year > 2009'
--   order: author, title asc
--   limit: 5
--   group: author
-- ...

local stringify = pandoc.utils.stringify

local function read_metadata_file(fname)
  local metafile = io.open(fname, 'r')
  local content = metafile:read("*a")
  metafile:close()
  local metadata = pandoc.read(content, "markdown").meta
  return metadata
end

local function parse_selector(val)
  local where = ''
  local order = ''
  local groupby = ''
  local limit
  if val.where then
    where = stringify(val.where)
    end
  if val.order then
    order = stringify(val.order)
    end
  if val.group then
    groupby = stringify(val.group)
  end
  if val.limit then
    limit = tonumber(stringify(val.limit))
  end
  local field, comparison, value =
              string.match(where, "%s*([%w_-]+)%s*([!=<>]+)%s(.*)")
  local orderings = {}
  for x in string.gmatch(order, "[%w_-]+") do
    if x == 'asc' and #orderings > 0 then
      orderings[#orderings][2] = true
    elseif x == 'desc' and #orderings > 0 then
      orderings[#orderings][2] = false
    else
      orderings[#orderings + 1] = {x, true}
    end
  end
  return { source = stringify(val.from),
           field  = stringify(val.select),
           condition =
             function (t)
               if not field then
                 return true
               end
               local target = t[field]
               if not target then
                 return false
               end
               local targetstr = stringify(target)
               if comparison == '==' or comparison == '=' then
                 return (targetstr == value)
               elseif comparison == '>' then
                 return (targetstr > value)
               elseif comparison == '>=' then
                 return (targetstr >= value)
               elseif comparison == '<' then
                 return (targetstr < value)
               elseif comparison == '<=' then
                 return (targetstr <= value)
               elseif comparison == '!=' then
                 return (targetstr ~= value)
               else
                 error("Unknown comparison operator " .. comparison)
               end
             end,

           order =
             function(x,y)
               for _,ord in pairs(orderings) do
                 local f, ascending = table.unpack(ord)
                 local xs = x[f] and stringify(x[f])
                 local ys = y[f] and stringify(y[f])
                 if xs and (xs < ys) then
                   return ascending
                 elseif ys and (xs > ys) then
                   return (not ascending)
                 end
               end
               return false
             end,

           group =
             function (t)
               if not groupby then
                 return t
               else
                 local ts = {}
                 local index = {}
                 for _,x in pairs(t) do
                   local k = (x[groupby] and stringify(x[groupby])) or ''
                   local i
                   if index[k] then
                     table.insert(ts[index[k]].items, x)
                   else
                     local new = pandoc.MetaMap({})
                     new[groupby] = k
                     new.items = pandoc.MetaList({x})
                     table.insert(ts, new)
                     index[k] = #ts
                   end
                 end
                 return ts
               end
             end,

             limit = limit
         }
end

local function get_selected_metadata(val)
  local selector = parse_selector(val)
  local meta = read_metadata_file(selector.source)
  for f in string.gmatch(selector.field, "[^%.]+") do
    meta = meta[f]
  end
  local metalist = {}
  local condition = selector.condition
  for k,v in pairs(meta) do
    if condition(v) then
      table.insert(metalist, v)
    end
  end
  if selector.order then
     table.sort(metalist, selector.order)
  end
  if selector.limit then
    local limit = selector.limit
    for i,_ in pairs(metalist) do
      if i > limit then
        metalist[i] = nil
      end
    end
  end
  return pandoc.MetaList(selector.group(metalist))
end

return {
  {
    Meta = function(meta)
      for k,val in pairs(meta) do
        if val['select'] then
          meta[k] = get_selected_metadata(val)
        end
      end
      return meta
    end,
  }
}
