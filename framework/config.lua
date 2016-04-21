local AppConfig = {}

AppConfig.__index = AppConfig

function AppConfig:new()
    return setmetatable({}, AppConfig)
end

return AppConfig
