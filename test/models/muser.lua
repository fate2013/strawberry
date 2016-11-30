local ActiveRecord = require "framework.db.mongo.active_record"
local mongo_config = require "app.config.mongo"

local MUser = {
    collection_name = "user",
}

MUser.__index = MUser

setmetatable(MUser, {
    __index = ActiveRecord,
})

return MUser
