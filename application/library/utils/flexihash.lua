local Flexihash = {
    obj = nil
}

Flexihash.__index = Flexihash

function Flexihash:instance()
    if self.obj then
        return self.obj
    end

    self.obj = setmetatable({
        replicas = 64,
        hasher = 'crc32',
        target_count = 0,
        position2target = {},
        target2positions = {},
        position2target_sorted = false,
    }, self)
    return self.obj
end

function 

return Flexihash
