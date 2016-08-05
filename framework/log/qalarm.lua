local cjson = require "cjson.safe"

local Qalarm = {
    path = "/var/wd/wrs/logs/alarm/",
    logger = "alarm.log",
    log_formater = {
        project = "lua",
        module = "",
        code = "",
        env = "prod",
        time = "",
        server_ip = "",
        client_ip = "",
        script = "",
        message = "",
        url = "",
        post_data = "",
        cookie = "",
    },
}

Qalarm.__index = Qalarm

function Qalarm:new()
    local instance = setmetatable({}, Qalarm)
    return instance
end

local function write_to_text(self)
    local file, err = io.open(self.path)
    if not file then
        os.execute("mkdir " .. self.path)
    end
    local log = cjson.encode(self.log_formater) .. "\n"
    local file = io.open(self.path .. self.logger, "a")
    file:write(log)
    file:close()
end

function Qalarm:send(project, module, code, message)
    if not code then code = "" end
    if not message then message = "" end
    local server_addr = ngx.var.server_addr
    if not server_addr then
        server_addr = ""
    end
    local client_addr = ngx.var.remote_addr
    if not client_addr then
        client_addr = ""
    end
    local request_uri = ngx.var.request_uri
    if not request_uri then
        request_uri = ""
    end
    local http_cookie = ngx.var.http_cookie
    if not http_cookie then
        http_cookie = ""
    end

    self.log_formater["project"] = tostring(project)
    self.log_formater["module"] = tostring(module)
    self.log_formater["code"] = tostring(code)

    self.log_formater["message"] = tostring(message)
    self.log_formater["server_ip"] = server_addr
    self.log_formater["client_ip"] = client_addr
    self.log_formater["time"] = tostring(os.time())


    local file = ""
    local line = ""

    local traceback_arr = string.split(debug.traceback(), "\n\9")

    if #traceback_arr >= 3 then
        local first_line_arr = string.split(traceback_arr[3], ":")
        file = first_line_arr[1]
        line = first_line_arr[2]
    end

    self.log_formater['script'] = file .. ":" .. line

    self.log_formater['url'] = request_uri
    self.log_formater['cookie'] = http_cookie
    self.log_formater['post_data'] = ngx.req.get_post_args()
    write_to_text(self)
end

return Qalarm
