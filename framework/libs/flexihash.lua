-- TODO more hash alg
-- TODO refactor with ffi
local Flexihash = {}

Flexihash.__index = Flexihash

local DEFAULT_REPLICAS = 64

local function empty_table(tbl)
    for k, v in pairs(tbl) do
        return false
    end
    return true
end

function Flexihash:instance(replicas)
    if not replicas then replicas = DEFAULT_REPLICAS end

    local obj = setmetatable({
        _replicas = replicas,
        _target_count = 0,
        _position_target_pairs = {},
        _target2indexes = {},
        _position_sorted = false,
    }, self)
    return obj
end

function Flexihash:add_target(target, weight)
    if not weight then weight = 1 end
    
    if self._target2indexes[target] then
        return
    end

    self._target2indexes[target] = {}

    -- hash the target into multiple positions
    for i = 1, math.floor(self._replicas * weight) do
        position = ngx.crc32_long(target .. i)
        table.insert(self._position_target_pairs, {position, target}) -- lookup
        table.insert(self._target2indexes[target], #self._position_target_pairs) -- target removal
    end

    self._position_sorted = false
    self._target_count = self._target_count + 1

    return self
end

function Flexihash:add_targets(targets, weight)
    for k, target in pairs(targets) do
        self:addTarget(target, weight)
    end

    return self
end

function Flexihash:remove_target(target)
    if not self._target2indexes[target] then
        return
    end

    for _, index in pairs(self._target2indexes[target]) do
        table.remove(self._position_target_pairs, index)
    end

    self._target2indexes[target] = nil

    self._target_count = self._target_count - 1

    return self;
end

function Flexihash:get_all_targets()
    local targets = {}
    for target, _ in pairs(self._target2indexes) do
        table.insert(targets, target)
    end
    return targets
end

function Flexihash:lookup(resource)
    -- handle no targets
    if empty_table(self._position_target_pairs) then
        return
    end

    -- optimize single target
    if self._target_count == 1 then
        for target, _ in pairs(self._target2indexes) do
            return target
        end
    end
    local resource_position = ngx.crc32_long(resource)

    self:_sort_position_targets()

    local lower = 1
    local higher = #self._position_target_pairs

    if self._position_target_pairs[higher][1] <= resource_position or self._position_target_pairs[1][1] > resource_position then
        return self._position_target_pairs[1][2]
    end

    local middle
    while higher - lower > 1 do
        middle = math.ceil((lower + higher) / 2)
        if resource_position < self._position_target_pairs[middle][1] then
            higher = middle
        else
            lower = middle
        end
    end

    return self._position_target_pairs[higher][2]
end

-- TODO need optimize
function Flexihash:lookup_list(resource, requested_count)
    if not requested_count or requested_count < 1 then
        return
    end

    -- handle no targets
    if empty_table(self._position_target_pairs) then
        return
    end

    -- optimize single target
    if self._target_count == 1 then
        for target, _ in pairs(self._target2indexes) do
            return {target}
        end
    end

    -- hash resource to a position
    local resource_position = ngx.crc32_long(resource)

    local results = {}
    local results_map = {}
    local collect = false

    self:_sort_position_targets()
    
    -- search values above the resourcePosition
    for _, position_target in pairs(self._position_target_pairs) do
        -- start collecting targets after passing resource position
        if not collect and position_target[1] > resource_position then
            collect = true
        end

        -- only collect the first instance of any target
        if collect and not results_map[position_target[2]] then
            table.insert(results, position_target[2])
            results_map[position_target[2]] = 1
        end

        -- return when enough results, or list exhausted
        if #results == requested_count or #results == self._target_count then
            return results
        end
    end

    -- loop to start - search values below the resourcePosition
    for _, position_target in pairs(self._position_target_pairs) do
        if not results_map[position_target[2]] then
            table.insert(results, position_target[2])
            results_map[position_target[2]] = 1
        end

        -- return when enough results, or list exhausted
        if #results == requested_count or #results == self._target_count then
            return results
        end

    end

    -- return results after iterating through both "parts"
    return results
end

Flexihash.__tostring = function(self)
    return "Flexihash{targets:[" .. table.concat(self:get_all_targets(), ",") .. "]}"
end

-- Sorts the internal mapping (positions to targets) by position
function Flexihash:_sort_position_targets()
    -- sort by key (position) if not already
    if not self._position_sorted then
        table.sort(self._position_target_pairs, function(a, b) return a[1] < b[1] end)
        self._position_sorted = true
        for target, _ in pairs(self._target2indexes) do
            self._target2indexes[target] = {}
        end
        for index, position_target in pairs(self._position_target_pairs) do
            table.insert(self._target2indexes[position_target[2]], index)
        end
    end
end

return Flexihash
