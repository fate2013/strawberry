-- dep
-- https://github.com/pintsized/lua-resty-http
local http_handle = require('framework.libs.http').new()

-- perf
local setmetatable = setmetatable

local HttpClient = {}

function HttpClient:new()
	local instance = {
		http_handle = http_handle,
		get = self.get
	}
	setmetatable(instance, HttpClient)
	return instance
end

local function request(self, url, method, params, headers, timeout)
    self.http_handle:set_timeout(timeout)
	local res, err = self.http_handle:request_uri(url, {
		method = method,
		body = params,
		headers = headers
    })
    return res
end

function HttpClient:get(url, params, headers, timeout)
    return request(self, url, "GET", '', headers, timeout)
end

function HttpClient:post(url, params, headers, timeout)
    return request(self, url, "POST", params, headers, timeout)
end

function HttpClient:put(url, params, headers, timeout)
    return request(self, url, "PUT", params, headers, timeout)
end

function HttpClient:delete(url, params, headers, timeout)
    return request(self, url, "DELETE", params, headers, timeout)
end

return HttpClient
