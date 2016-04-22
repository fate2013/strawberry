require "framework.functions"
local Error = require 'framework.error'
local Dispatcher = require 'framework.dispatcher'
local Registry = require('framework.registry'):new('sys')
local Utils = require 'framework.libs.utils'
local ServiceLocator = require "framework.di.service_locator"

-- perf
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable

local function new_dispatcher(self)
    return Dispatcher:new(self)
end

local function new_bootstrap_instance(lbootstrap, dispatcher)
    return require(lbootstrap):new(dispatcher)
end

local Application = {}

local application = nil

setmetatable(Application, {
    __index = ServiceLocator,
})

function Application:lpcall( ... )
    local ok, rs_or_error = pcall( ... )
    if ok then
        return rs_or_error
    else
        self:error_response(500, rs_or_error)
    end
end

function Application:error_response(code, msg)
    self.dispatcher:errResponse(code, msg)
end

local function load_app_config(self)
    local config = require_dir(self.config.module_name .. ".config")
    for k, v in pairs(config) do
        self.config[k] = v
    end
end

local function buildconf(self, config)
    self.config = config
    load_app_config(self)
end

local function register_components(self)
    if self.config.app.components then
        for id, definition in pairs(self.config.app.components) do
            if definition["singleton"] then
                local Class = require(definition['class'])
                definition['class'] = nil
                definition['singleton'] = nil
                self:instance(id, Class:new(definition))
            else
                definition['singleton'] = nil
                self:register(id, definition)
            end
        end
    end
end

function Application:new(config)
    if not application then
        buildconf(self, config)
        local instance = ServiceLocator:new()
        setmetatable(instance, {__index = Application})

        register_components(instance)
        application = instance
        Registry.app = application
        instance.dispatcher = self:lpcall(new_dispatcher, self)
    end
    return application
end

function Application:bootstrap()
    local lbootstrap = self.config.module_name .. '.bootstrap'
    bootstrap_instance = self:lpcall(new_bootstrap_instance, lbootstrap, self.dispatcher)
    self:lpcall(bootstrap_instance.bootstrap, bootstrap_instance)
    return self
end

function Application:run()
    self:lpcall(self.dispatcher.dispatch, self.dispatcher)
end

return Application
