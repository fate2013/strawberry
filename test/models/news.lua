local ActiveRecord = require "framework.http.active_record"
local http_config = require "test.config.http"

local News = {
    domain = http_config.default_domain,
    list_api = "/news",
}

News.__index = News

setmetatable(News, {
    __index = ActiveRecord,
})

return News
