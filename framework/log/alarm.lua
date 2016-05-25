local cjson = require "cjson.safe"

local Alarm = {
    path = "/var/wd/wrs/logs/alarm/",
    log_formater = {
        flags = "project",
        time = "",
        ip = "",
        level = 0,
        code = 0,
        file = "",
        line = 1,
        message = "",
        url = "",
        post_data = "",
        cookie = "",
    },
}

Alarm.__index = Alarm

function Alarm:new()
    local instance = setmetatable({}, Alarm)
    return instance
end

local function write_to_text(self, flags)
    local file, err = io.open(self.path)
    if not file then
        os.execute("mkdir " .. self.path)
    end
    log = cjson.encode(self.log_formater) .. "\n"
    local file = io.open(self.path .. flags .. ".log","a")
    file:write(log)
    file:close()
end

function Alarm:write(flags, code, level, message)
    if not level then level = 0 end
    if not message then message = "" end
    local server_addr = ngx.var.server_addr
    if not server_addr then
        server_addr = ""
    end
    local request_uri = ngx.var.request_uri
    if not request_uri then
        request_uri = ""
    end
    local http_cookie = ngx.var.http_cookie
    if not http_cookie then
        http_cookie = ""
    end

    self.log_formater["flags"] = tostring(flags)
    self.log_formater["code"] = tostring(code)
    self.log_formater["level"] = tostring(level)
    self.log_formater["message"] = tostring(message)
    self.log_formater["ip"] = server_addr
    self.log_formater["time"] = tostring(os.time())

    local file = ""
    local line = ""
    local traceback_arr = string.split(debug.traceback(), "\n\9")
    if #traceback_arr >= 2 then
        local first_line_arr = string.split(traceback_arr[2], ":")
        file = first_line_arr[1]
        line = first_line_arr[2]
    end
    self.log_formater['file'] = file
    self.log_formater['line'] = line

    self.log_formater['url'] = request_uri
    self.log_formater['cookie'] = http_cookie
    self.log_formater['post_data'] = ngx.req.get_post_args()
    write_to_text(self, flags)
end

return Alarm
