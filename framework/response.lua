local cjson = require "cjson.safe"

local Registry = require('framework.registry'):new('sys')
-- perf
local setmetatable = setmetatable

local Response = {}
Response.__index = Response

function Response:new()
    ngx.header['Content_type'] = 'text/html; charset=UTF-8'
    ngx.header['Power_By'] = 'Strawberry-' .. Registry.app.config.version
    local instance = {
        status = 200,
        headers = {},
        append_body = '',
        body = '',
        prepend_body = ''
    }
    setmetatable(instance, Response)
    instance:setHeaders({
        ["Access-Control-Allow-Headers"] = "x-requested-with,content-type,Access-Control-Allow-Origin,cache-control",
        ["Access-Control-Allow-Origin"] = "http://union2.sit.ffan.com:3330",
        ["Access-Control-Allow-Methods"] = "POST, PUT, GET, OPTIONS, DELETE",
        ["Access-Control-Allow-Credentials"] = "true"
    })
    return instance
end

function Response:appendBody(append_body)
    if append_body ~= nil and type(append_body) == 'string' then
        self.append_body = append_body
    else
        error({ code = 105, msg = {AppendBodyErr = 'append_body must be a not empty string.'}})
    end
end

function Response:clearBody()
    self.body = nil
end

function Response:clearHeaders()
    for k,_ in pairs(ngx.header) do
        ngx.header[k] = nil
    end
end

function Response:getBody()
    return self.body
end

function Response:getHeader()
    return self.headers
end

function Response:prependBody(prepend_body)
    if prepend_body ~= nil and type(prepend_body) == 'string' then
        self.prepend_body = prepend_body
    else
        error({ code = 105, msg = {PrependBodyErr = 'prepend_body must be a not empty string.'}})
    end
end

function Response:response()
    local body = {[1]=self.append_body, [2]=self.body, [3]=self.prepend_body}
    ngx.print(table.concat(body, ""))
    return true
end

function Response:setBody(body)
    if body ~= nil then self.body = body end
end

function Response:setStatus(status)
    if status ~= nil then self.status = status end
end

function Response:setHeaders(headers)
    if headers ~=nil then
        for header,value in pairs(headers) do
            ngx.header[header] = value
        end
    end
    return self
end

function Response:setHeader(key, value)
	ngx.header[key] = value
    return self
end

function Response:appendHeader(key, value)
    local orig_value = ngx.header[key]
    local new_value
    if type(orig_value) == "table" then
        new_value = orig_value
        Utils.tappend(new_value, value)
    else
        new_value = {orig_value, value}
    end

    ngx.header[key] = new_value
    return self
end

function Response:send_json(data, code, msg)
    if not code then code = 200 end
    if not msg then msg = "OK" end
    self:setHeader("Content-Type", "application/json; charset=UTF-8")
    return cjson.encode({status = code, message = msg, data = data})
end

function Response:success()
    self:setHeader("Content-Type", "application/json; charset=UTF-8")
    return cjson.encode({status = 200, message = "OK", data = {}})
end

function Response:error(code, msg)
    if not code then code = 500 end
    if not msg or not Registry.app:get("config"):get("app")["debug"] and code == 500 then msg = "服务器错误" end
    self:setHeader("Content-Type", "application/json; charset=UTF-8")
    return cjson.encode({status = code, message = msg, data = {}})
end

function Response:send_raw(payload, content_type)
    if not content_type then
        content_type = "application/json"
    end
    self:setHeader("Content-Type", content_type .. "; charset=UTF-8")
    return payload
end

return Response
