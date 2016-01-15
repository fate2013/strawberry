local table_dao = require('app.models.dao.table'):new()
local UserService = {}

function UserService:get()
    table_dao:set('zhou', 'j')
    return table_dao.zhou
end

return UserService
