local cjson = require "cjson"

local vanilla_response = require "vanilla.v.response"

local Response = {}
Response.__index = Response

setmetatable(Response, {
    __index = vanilla_response,
})

function Response:new()
    local instance = setmetatable({}, Response)

    return instance
end

function Response:send_json(payload)
    self:setHeader("Content-Type", "application/json")
    return cjson.encode(payload)
end

return Response
