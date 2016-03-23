local ActiveRecord = require "framework.api.active_record"
local http_config = require "test.config.http"

local News = {
    domain = http_config.default_domain,
    apis = {
        list = "/news",
        detail = "/news/{id}",
        create = "/news",
        update = "/news/{id}",
        delete = "/news/{id}",
    },
    primary_key = "id",
}

News.__index = News

setmetatable(News, {
    __index = ActiveRecord,
})

return News
