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
    Registry.app = self
    load_app_config(self)
end

function Application:new(config)
    buildconf(self, config)
    local instance = {
        run = self.run,
        bootstrap = self.bootstrap,
        --dispatcher = self:lpcall(new_dispatcher, self)
        dispatcher = new_dispatcher(self)
    }
    setmetatable(instance, {__index = Application})
    return instance
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
