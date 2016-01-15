-- TODO more hash alg
-- TODO refactor with ffi
local CRC = require "framework.libs.hasher.crc32"

local Flexihash = {
    obj = nil
}

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

    if self.obj then
        return self.obj
    end

    self.obj = setmetatable({
        _replicas = replicas,
        _target_count = 0,
        _position2target = {},
        _target2positions = {},
        _position2target_sorted = false,
    }, self)
    return self.obj
end

function Flexihash:add_target(target, weight)
    if not weight then weight = 1 end
    
    if self._target2positions[target] then
        return
    end

    self._target2positions[target] = {}

    -- hash the target into multiple positions
    for i = 1, math.floor(self._replicas * weight) do
        position = CRC.crc32(target .. i)
        self._position2target[position] = target -- lookup
        table.insert(self._target2positions[target], position) -- target removal
    end

    self._position2target_sorted = false
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
    if self._target2positions[target] then
        return
    end

    for k, position in pairs(self._target2positions[target]) do
        self._position2target[position] = nil
    end

    self._target2positions[target] = nil

    self._target_count = self._target_count - 1

    return self;
end

function Flexihash:get_all_targets()
    local targets = {}
    for target, _ in pairs(self._target2positions) do
        table.insert(targets, target)
    end
    return targets
end

function Flexihash:lookup(resource)
    targets = self:lookup_list(resource, 1)
    if not targets then
        return
    end
    return targets[1]
end

function Flexihash:lookup_list(resource, requested_count)
    if not requested_count or requested_count < 1 then
        return
    end

    -- handle no targets
    if empty_table(self._position2target) then
        return
    end

    -- optimize single target
    if self._target_count == 1 then
        for k, target in pairs(self._position2target) do
            return {target}
        end
    end

    -- hash resource to a position
    resource_position = CRC.crc32(resource)

    results = {}
    collect = false

    self:_sort_position_targets()
    
    -- search values above the resourcePosition
    for k, v in pairs(self._position2target) do
        -- start collecting targets after passing resource position
        if not collect and k > resource_position then
            collect = true
        end

        -- only collect the first instance of any target
        if  collect and not results[v] then
            table.insert(results, v)
        end

        -- return when enough results, or list exhausted
        if #results == requested_count or #results == self._target_count then
            return results
        end
    end

    -- loop to start - search values below the resourcePosition
    for k, v in pairs(self._position2target) do
        if not results[v] then
            table.insert(results, v)
        end

        -- return when enough results, or list exhausted
        if #results == requested_count or #results == self._target_count then
            return results
        end

    end

    -- return results after iterating through both "parts"
    return results
end

Flexihash.__tostring = function()
    return "Flexihash{targets:[" .. table.concat(self:get_all_targets(), ",") .. "]}"
end

-- Sorts the internal mapping (positions to targets) by position
function Flexihash:_sort_position_targets()
    -- sort by key (position) if not already
    if not self._positionToTargetSorted then
        table.sort(self._position2target)
        self._position2target_sorted = true
    end
end

return Flexihash
