local AppConfig = {}

AppConfig.__index = AppConfig

function AppConfig:new(config)
    return setmetatable({
        config = config
    }, AppConfig)
end

function AppConfig:get(key)
    return self.config[key]
end

return AppConfig
