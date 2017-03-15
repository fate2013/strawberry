-- dep
-- https://github.com/pintsized/lua-resty-http
local http = require('framework.libs.http')
local Utils = require "framework.libs.utils"

-- perf
local setmetatable = setmetatable

local HttpClient = {}

HttpClient.__index = HttpClient

function HttpClient:new()
	return setmetatable({
        http_handle = http:new(),
    }, self)
end

function HttpClient:request(url, method, params, headers, timeout_ms)
    self.http_handle:set_timeout(timeout_ms)
	local res, err = self.http_handle:request_uri(url, {
		method = method,
		body = params,
		headers = headers
    })
    if not res or not res.body then
        return nil
    end
    return res.body
end

local function build_params(params)
    local params_arr = {}
    for k, v in pairs(params) do
        Utils.tappend(params_arr, k .. "=" .. v)
    end
    return table.concat(params_arr, "&")
end

function HttpClient:get(url, params, headers, timeout_ms)
    if params then
        if string.find(url, '?') then
            url = url .. "&"
        else
            url = url .. "?"
        end
        url = url .. build_params(params)
    end
    return self:request(url, "GET", '', headers, timeout_ms)
end

function HttpClient:post(url, params, headers, timeout_ms)
    if not headers then
        headers = {}
    end
    if not headers["Content-Type"] then
        headers["Content-Type"] = "application/x-www-form-urlencoded"
    end
    return self:request(url, "POST", build_params(params), headers, timeout_ms)
end

function HttpClient:put(url, params, headers, timeout_ms)
    if not headers then
        headers = {}
    end
    if not headers["Content-Type"] then
        headers["Content-Type"] = "application/x-www-form-urlencoded"
    end
    return self:request(url, "PUT", build_params(params), headers, timeout_ms)
end

function HttpClient:delete(url, params, headers, timeout_ms)
    return self:request(url, "DELETE", build_params(params), headers, timeout_ms)
end

return HttpClient
