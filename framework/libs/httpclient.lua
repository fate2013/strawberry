local function tappend(t, v) t[#t+1] = v end

-- dep
-- https://github.com/pintsized/lua-resty-http
local http_handle = require('framework.libs.http').new()

-- perf
local setmetatable = setmetatable

local HttpClient = {
    http_handle = http_handle
}

HttpClient.__index = HttpClient

function HttpClient:new()
	return setmetatable({}, self)
end

local function request(self, url, method, params, headers, timeout_ms)
    self.http_handle:set_timeout(timeout_ms)
	local res, err = self.http_handle:request_uri(url, {
		method = method,
		body = params,
		headers = headers
    })
    return res.body
end

local function build_params(params)
    local params_arr = {}
    for k, v in pairs(params) do
        tappend(params_arr, k .. "=" .. v)
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
        print_r(url)
    end
    return request(self, url, "GET", '', headers, timeout_ms)
end

function HttpClient:post(url, params, headers, timeout_ms)
    if not headers then
        headers = {}
    end
    if not headers["Content-Type"] then
        headers["Content-Type"] = "application/x-www-form-urlencoded"
    end
    return request(self, url, "POST", build_params(params), headers, timeout_ms)
end

function HttpClient:put(url, params, headers, timeout_ms)
    if not headers then
        headers = {}
    end
    if not headers["Content-Type"] then
        headers["Content-Type"] = "application/x-www-form-urlencoded"
    end
    return request(self, url, "PUT", build_params(params), headers, timeout_ms)
end

function HttpClient:delete(url, params, headers, timeout_ms)
    return request(self, url, "DELETE", build_params(params), headers, timeout_ms)
end

return HttpClient
