local response = require "framework.response"
local User = require "test.models.user"
local Profile = require "test.models.profile"

local function tappend(t, v) t[#t+1] = v end

local TestController = {}

function TestController:mysqlclient()
    local mysql_client = require "framework.db.mysql.client"
    local client = mysql_client:new("127.0.0.1", 3306, "root", "", "fruit", 2000)
    local res = client:query("select * from user")
    return response:new():send_json(res)
end

function TestController:mysqlreplica_master()
    local mysql_replica = require "framework.db.mysql.replica"
    local config = require "test.config.mysql"
    local replica = mysql_replica:instance("activity", config.activity)
    if not replica then
        return "invalid mysql db specified"
    end
    local res = replica:master():query("select * from user")
    return response:new():send_json(res)
end

function TestController:mysqlreplica_slave()
    local mysql_replica = require "framework.db.mysql.replica"
    local config = require "test.config.mysql"
    local replica = mysql_replica:instance("activity", config.activity)
    if not replica then
        return "invalid mysql db specified"
    end
    local res = replica:slave():query("select * from user")
    return response:new():send_json(res)
end

function TestController:redisclient()
    local redis_client = require "framework.db.redis.client"
    local client = redis_client:new("127.0.0.1", 6379, 1000)
    res = client:query("get", "dog")
    return response:new():send_json(res)
end

local function _random_string(length)
    local res = ""
    for i = 1, length do
        res = res .. string.char(math.random(97, 122))
    end
    return res
end

function TestController:flexihash()
    local util_flexihash = require "framework.libs.flexihash"
    local flexihash = util_flexihash:instance()
    local targets = {
        "127.0.0.1:6379",
        "127.0.0.1:6380",
        "127.0.0.1:6381",
    }
    local freq = {}
    for k, target in pairs(targets) do
        flexihash:add_target(target)
        freq[target] = 0
    end

    math.randomseed(os.time())
    for i = 1, 1000 do
        local str = _random_string(3)
        --local target = flexihash:lookup_list(str, 1)[1]
        local target = flexihash:lookup(str)
        freq[target] = freq[target] + 1
    end

    return response:new():send_json(freq)
end

function TestController:crc32()
    local CRC = require "framework.libs.hasher.crc32"
    return tostring(CRC.crc32('aa'))
end

function TestController:rediscluster()
    local redis_cluster = require "framework.db.redis.cluster"
    local config = require "test.config.redis"
    local cluster = redis_cluster:instance("activity", config.cluster.activity)
    if cluster then
        return response:new():send_json(cluster:query("get", "dog"))
    else
        return "invalid redis cluster specified"
    end
end

function TestController:rediscluster2()
    local redis_cluster = require "framework.db.redis.cluster"
    local config = require "test.config.redis"
    local cluster = redis_cluster:instance("activity", config.cluster.activity)
    if cluster then
        return response:new():send_json(cluster:query("get", "dog"))
    else
        return "invalid redis cluster specified"
    end
end

function TestController:redisclusterop()
    local redis_cluster = require "framework.db.redis.cluster"
    local config = require "test.config.redis"
    local cluster = redis_cluster:instance("activity", config.cluster.activity)
    if cluster then
        --return response:new():send_json(cluster:query("hset", "doghash", "t", "abcde", "aaa"))
        return response:new():send_json(cluster:query("hget", "doghash", "t"))
    else
        return "invalid redis cluster specified"
    end
end

function TestController:error()
    return response:new():error(404, "Resource not found")
end

function TestController:test()
    local client = require("framework.libs.httpclient"):new()
    local res = client:get("http://127.0.0.1/",'GET','',{},0)

    return res.body
end

function TestController:redismget()
    local redis_client = require "framework.db.redis.client"
    local client = redis_client:new("127.0.0.1", 6379, 1000)
    local res = client:query("mget", unpack({"dog", "aaaa", "bbbb"}))
    return response:new():send_json(res)
end

function TestController:redisreplica_master()
    local redis_replica = require "framework.db.redis.replica"
    local config = require "test.config.redis"
    local replica = redis_replica:instance("activity", config.replica.activity)
    local res = replica:master():query("mget", "dog", "aaaa", "bbbb")
    return response:new():send_json(res)
end

function TestController:redisreplica_slave()
    local redis_replica = require "framework.db.redis.replica"
    local config = require "test.config.redis"
    local replica = redis_replica:instance("activity", config.replica.activity)
    local res = replica:slave():query("mget", "dog", "aaaa")
    return response:new():send_json(res)
end

function TestController:log()
    ngx.log(ngx.ERR, "hello log, ", "abc")
    return 'abc'
end

function TestController:active_record_get()
    local user = User:find()
        :select({"name"})
        --:from("user")
        --:where("name", "zhangkh")
        --:where_in("name", {"zhangkh", "zcc"})
        --:where_like("name", "z%")
        :where_multi({"or", "name='zhangkh'", {"and", "id=2", "name='zcc'"}})
        :group_by('name')
        --:order_by({'id', 'desc'})
        --:order_by({'name', 'asc'})
        :limit(2):offset(0)
        :one()
    return response:new():send_json(user:to_array())
end

function TestController:active_record_new()
    local user = User:new()
    user.name = 'syt'
    user.phone = '13500000000'
    user.pwd = ngx.md5('123456')
    user:save()

    return response:new():success()
end

function TestController:active_record_update()
    local user = User:find():one()
    user.name = 'zhangkh'
    user.phone = '15652918035'
    user:save()

    return response:new():success()
end

function TestController:active_record_has_one()
    local user = User:find():one()
    local profile = user:profile():get()
    profile.height = 180
    profile:save()
    return response:new():send_json(profile:to_array())
end

function TestController:active_record_has_many()
    local user = User:find():one()
    local orders = user:orders():get()
    local order_list = {}
    for _, order in ipairs(orders) do
        tappend(order_list, order:to_array())
    end

    return response:new():send_json(order_list)
end

function TestController:active_record_belongs_to()
    local profile = Profile:find():one()
    local user = profile:user():get()
    return response:new():send_json(user:to_array())
end

function TestController:active_record_belongs_to_many()
    local user = User:find():one()
    local roles = user:roles():get()
    local role_list = {}
    for _, role in ipairs(roles) do
        tappend(role_list, role:to_array())
    end
    return response:new():send_json(role_list)
end

return TestController
