local httpclient = require("framework.libs.httpclient"):new()

local ActiveRecord = {
    domain = "",
    list_api = "",
    detail_api = "",
    create_api = "",
    update_api = "",
    delete_api = "",
}

ActiveRecord.__index = ActiveRecord

function ActiveRecord:new()
    return setmetatable({}, ActiveRecord)
end

function ActiveRecord:list()
    return httpclient:
end

return ActiveRecord
