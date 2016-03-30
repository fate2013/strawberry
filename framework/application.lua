local Error = require 'framework.error'
local sys_conf = require 'framework.config'
local Dispatcher = require 'framework.dispatcher'
local Registry = require('framework.registry'):new('sys')
local Utils = require 'framework.libs.utils'

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

function Application:buildconf(config)
    if config ~= nil then
        for k,v in pairs(config) do sys_conf[k] = v end
    end
    if sys_conf.name == nil or sys_conf.app.root == nil then
        self:error_response(500, [[
            Sys Err: Please set app name and app root in config/application.lua like:
            
                Appconf.name = 'strawberry'
                Appconf.app.root='./'
            ]])
    end
    Registry['app_name'] = sys_conf.name
    Registry['app_root'] = sys_conf.app.root
    Registry['app_version'] = sys_conf.version
    return sys_conf
end

function Application:new(config)
    self.config = self:buildconf(config)
    local instance = {
        run = self.run,
        bootstrap = self.bootstrap,
        dispatcher = self:lpcall(new_dispatcher, self)
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Application:bootstrap()
    local lbootstrap = 'app.bootstrap'
    if self.config['bootstrap'] ~= nil then
        lbootstrap = self.config['bootstrap']
    end
    bootstrap_instance = self:lpcall(new_bootstrap_instance, lbootstrap, self.dispatcher)
    self:lpcall(bootstrap_instance.bootstrap, bootstrap_instance)
    return self
end

function Application:run()
    self:lpcall(self.dispatcher.dispatch, self.dispatcher)
end

return Application
