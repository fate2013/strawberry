local Controller = require 'framework.controller'
local Request = require 'framework.request'
local Router = require 'framework.router'
local Response = require 'framework.response'
local View = require 'framework.views.rtpl'
local Error = require 'framework.error'

-- perf
local error = error
local pairs = pairs
local require = require
local setmetatable = setmetatable
local function tappend(t, v) t[#t+1] = v end

local function new_view(view_conf)
    return View:new(view_conf)
end

local function run_route(router_instance)
    return router_instance:route()
end

local Dispatcher = {}

function Dispatcher:new(application)
    self.request = Request:new()
    self.response = Response:new()
    self.router = Router:new(self.request)
    local instance = {
        application = application,
        plugins = {},
        controller_prefix = application.config.controller.prefix,
        error_controller = 'error',
        error_action = 'error'
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Dispatcher:getRequest()
    return self.request
end

function Dispatcher:setRequest(request)
    self.request = request
end

function Dispatcher:getResponse()
    return self.response
end

function Dispatcher:registerPlugin(plugin)
    if plugin ~= nil then tappend(self.plugins, plugin) end
end

function Dispatcher:_runPlugins(hook)
    for _, plugin in ipairs(self.plugins) do
        if plugin[hook] ~= nil then
            plugin[hook](plugin, self.request, self.response)
        end
    end
end

function Dispatcher:getRouter()
    return self.router
end

function Dispatcher:_route()
    local controller_name_or_error, action= run_route(self.router)
    if controller_name_or_error then
        self.request.controller_name = controller_name_or_error
        self.request.action_name = action
    end
end

local function require_controller(controller_prefix, controller_name)
    return require(controller_prefix .. controller_name)
end

local function call_controller(Dispatcher, matched_controller, controller_name, action_name)
    if matched_controller[action_name] == nil then
        Dispatcher:errResponse(102, {NoAction = action_name})
    end
    Dispatcher:initView()
    local body = matched_controller[action_name](matched_controller)
    if body ~= nil then return body
    else
        Dispatcher:errResponse(104, {Exec_Err = controller_name .. '/' .. action_name})
    end
end

function Dispatcher:dispatch()
    self:_runPlugins('routerStartup')
    self:_route()
    self:_runPlugins('routerShutdown')
    self.controller = Controller:new(self.request, self.response, self.application.config)
    if self.application.config.view then
        self.view = pcall(new_view(self.application.config.view))
    end
    self:_runPlugins('dispatchLoopStartup')
    self:_runPlugins('preDispatch')
    local matched_controller = require_controller(self.controller_prefix, self.request.controller_name)
    setmetatable(matched_controller, { __index = self.controller })
    local c_rs = call_controller(self, matched_controller, self.request.controller_name, self.request.action_name)
    if type(c_rs) ~= 'string' then
        self:errResponse(103, {Rs_Error = self.request.controller_name .. '/' .. self.request.action_name .. ' must return a String.'})
    end
    self.response.body = c_rs
    self:_runPlugins('postDispatch')
    self.response:response()
    self:_runPlugins('dispatchLoopShutdown')
end

function Dispatcher:initView(view, controller_name, action_name)
    if view ~= nil then self.view = view end
    self.controller:initView(self.view, controller_name, action_name)
end

function Dispatcher:errResponse(code, msg)
    self.response.body = self.response:error(code, msg)
    self.response:response()
    ngx.eof()
end

function Dispatcher:getApplication()
    return self.application
end

function Dispatcher:setView(view)
    self.view = view
end

function Dispatcher:returnResponse()
    return self.response
end

function Dispatcher:setDefaultAction(default_action)
    if default_action ~= nil then self.request.action_name = default_action end
end

function Dispatcher:setDefaultController(default_controller)
    if default_controller ~= nil then self.request.controller_name = default_controller end
end

function Dispatcher:setErrorHandler(err_handler)
    if type(err_handler) == 'table' then
        if err_handler['controller'] ~= nil then self.error_controller = err_handler['controller'] end
        if err_handler['action'] ~= nil then self.error_action = err_handler['action'] end
        return true
    end
    return false
end

return Dispatcher
