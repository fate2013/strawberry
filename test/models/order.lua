local ActiveRecord = require "framework.db.mysql.active_record"
local mysql_config = require "test.config.mysql"

local Order = {
    table_name = "order_form",
    config_group = "default",
    config = mysql_config["default"],
}
Order.__index = Order

setmetatable(Order, {
    __index = ActiveRecord,
})

return Order
