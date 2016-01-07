local ngx_conf = {}

ngx_conf.common = {
    INIT_BY_LUA = 'nginx.init',
    LUA_SHARED_DICT = 'nginx.sh_dict',
    -- LUA_PACKAGE_PATH = '',
    -- LUA_PACKAGE_CPATH = '',
    CONTENT_BY_LUA_FILE = './pub/index.lua'
}

ngx_conf.env = {}
ngx_conf.env.development = {
    LUA_CODE_CACHE = false,
    PORT = 9110
}

ngx_conf.env.test = {
    LUA_CODE_CACHE = true,
    PORT = 9111
}

ngx_conf.env.production = {
    LUA_CODE_CACHE = true,
    PORT = 80
}

return ngx_conf
