local response = require "framework.response"
local User = require "test.models.user"
local Profile = require "test.models.profile"
local Role = require "test.models.role"
local News = require "test.models.news"
local cjson = require "cjson.safe"

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

function TestController:redispipeline()
    local Connection = require "framework.db.redis.connection"
    local connection = Connection:new("127.0.0.1", 6379, 1000)
    local res = cjson.encode(connection:pipeline({{"set", "aa", 5}, {"incr", "aa"}}))
    return res
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
    local res = client:get("http://127.0.0.1/", {}, 0)

    return res
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
        --:order_by('id', 'desc')
        --:order_by('name', 'asc')
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
    local user_addr = user.profile.user_addr
    user_addr.addr = "aaa"
    user_addr:save()
    return response:new():send_json(user_addr:to_array())
end

function TestController:active_record_has_many()
    local user = User:find():one()
    local orders = user.orders
    local order_list = {}
    for _, order in ipairs(orders) do
        tappend(order_list, order:to_array())
    end

    return response:new():send_json(order_list)
end

function TestController:active_record_belongs_to()
    local profile = Profile:find():one()
    local user = profile.user
    return response:new():send_json(user:to_array())
end

function TestController:active_record_belongs_to_many()
    local user = User:find():one()
    local roles = user.roles
    local roles_list = {}
    for _, role in ipairs(roles) do
        tappend(roles_list, role:to_array())
    end

    local role = Role:find():one()
    local users = role.users
    local users_list = {}
    for _, user in ipairs(users) do
        tappend(users_list, user:to_array())
    end

    return response:new():send_json({
        roles = roles_list,
        users = users_list,
    })
end

function TestController:active_record_has_one_with()
    local user = User:find():with("profile.user_addr"):as_array():one()
    return response:new():send_json(user.profile.user_addr)
end

function TestController:active_record_has_many_with()
    local user = User:find():with("orders"):as_array():one()
    local orders = user.orders

    return response:new():send_json(orders)
end

function TestController:active_record_belongs_to_with()
    local profile = Profile:find():with("user"):as_array():one()
    local user = profile.user
    return response:new():send_json(user)
end

function TestController:active_record_belongs_to_many_with()
    local user = User:find():with("roles"):as_array():one()
    local roles = user.roles

    local role = Role:find():order_by("id", "desc"):with("users"):as_array():one()
    local users = role.users
    return response:new():send_json({
        roles = roles,
        users = users,
    })   
end

function TestController:http_ar_list()
    local news = News:find():as_array():all()
    return response:new():send_json(news)
end

function TestController:http_ar_detail()
    local news = News:find():where("id", 1):one()
    return response:new():send_json(news:to_array())
end

function TestController:http_ar_create()
    local news = News:new()
    news.title = 'test title'
    news.content = 'test content'
    local ret = cjson.decode(news:save())
    return response:new():send_json(ret)
end

function TestController:http_ar_update()
    local news = News:find():where("id", 1):one()
    news.title = "title1"
    local ret = cjson.decode(news:save())
    return response:new():send_json(ret)
end

function TestController:countdownlatch()
    local Connection = require "framework.db.redis.connection"
    local connection = Connection:new("127.0.0.1", 6379, 1000)
    local CountdownLatch = require "framework.concurrent.countdownlatch.countdownlatch"
    local countdownlatch = CountdownLatch:new("test", 5, "redis", connection)
    local ret
    for i = 1, 5 do
        ret = countdownlatch:countdown()
    end
    countdownlatch:countdown()
    ret = countdownlatch:countdown()

    return string.format("%s", ret)
end

function TestController:queue()
    local Connection = require "framework.db.redis.connection"
    local connection = Connection:new("127.0.0.1", 6379, 1000)
    local Queue = require "framework.queue.queue"
    local queue = Queue:new("test_queue", "redis", connection)
    queue:push("aaa")
    local ele = queue:pop()

    return ele
end

return TestController
