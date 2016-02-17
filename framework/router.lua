local lrucache = require "resty.lrucache"

-- perf
local error = error
local function tappend(t, v) t[#t+1] = v end

-- init Router and set routes
local Router = {}

local ERR_ROUTE_NONE = "err_none"
local ERR_ROUTE_EMPTY = "err_empty"
local CACHE_CAPACITY = 1000

-- maybe overflow
local cache = lrucache.new(CACHE_CAPACITY)

function Router:new(request)
    local instance = {
        routes = {require('framework.routes.simple'):new(request)},
    	request = request,
    }

    setmetatable(instance, {__index = self})
    return instance
end

function Router:addRoute(route, only_one)
    if route ~= nil then
        if only_one then self.routes = {} end
        tappend(self.routes, route)
    end
end

function Router:removeRoute(route_name)
    for i,route in ipairs(self.routes) do
        if (tostring(route) == route_name) then self.routes[i] = nil end
    end
end

function Router:getRoutes()
    return self.routes
end

function Router:getCurrentRoute()
    return self.current_route
end

function Router:getCurrentRouteName()
    return tostring(self.current_route)
end

local function route_match(route)
    return route:match()
end

function Router:route()
    -- lookup route from cache
    local controller_action = cache:get(self.request.uri)
    if controller_action then
        ngx.log(ngx.DEBUG, "hit cache")
        if controller_action == ERR_ROUTE_NONE then
            error({ code = 202, msg = {Routes_No_Match = #self.routes .. "Routes All Didn't Match."}})
        elseif controller_action == ERR_ROUTE_EMPTY then
            error({ code = 201, msg = {Empty_Routes = 'Null routes added.'}})
        else
            return controller_action[1], controller_action[2]
        end
    end
    ngx.log(ngx.WARN, "Route cache miss, maybe lrucache reaches limit ", CACHE_CAPACITY)
    if #self.routes >= 1 then
        for _,route in ipairs(self.routes) do
            local ok, controller_name_or_error, action = pcall(route_match, route)
            if ok and controller_name_or_error then
                self.current_route = route
                cache:set(self.request.uri, {controller_name_or_error, action})
                return controller_name_or_error, action
            end
        end
        cache:set(self.request.uri, ERR_ROUTE_NONE)
        error({ code = 202, msg = {Routes_No_Match = #self.routes .. "Routes All Didn't Match."}})
    end
    cache:set(self.request.uri, ERR_ROUTE_EMPTY)
    error({ code = 201, msg = {Empty_Routes = 'Null routes added.'}})
end

return Router
