-- custom functions
function sprint_r( ... )
    local helpers = require 'framework.libs.utils'
    return helpers.sprint_r(...)
end

function lprint_r( ... )
    local rs = sprint_r(...)
    print(rs)
end

function print_r( ... )
    local rs = sprint_r(...)
    ngx.say(rs)
end

function err_log(msg)
    ngx.log(ngx.ERR, "===debug" .. msg .. "===")
end

function string.split(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil 
    end 
                        
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end 
    return result
end 

-- TODO support recursive
-- dir: e.g. app.config
function require_dir(dir)
    if dir == nil then return end

    local loaded = {}
    local getinfo = io.popen('ls ' .. ngx.var.root .. '/' .. string.gsub(dir, '%.', '/') .. '/*.lua')
    local all = getinfo:read('*all')

    local paths = string.split(all, "\n")
    for _, path in ipairs(paths) do
        if path ~= '' then
            path = string.sub(path, 0, -5)
            _, _, path = string.find(path, '.*/(.-)$')
            loaded[path] = require(dir .. "." .. path)
        end
    end

    return loaded
end
