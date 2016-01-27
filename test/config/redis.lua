local RedisConf = {}

RedisConf.cluster = {
    default = {
        {
            host = "127.0.0.1",
            port = 6379,
            timeout = 1000,
        },
        {
            host = "127.0.0.1",
        },
        {
            host = "127.0.0.1",
        },
    },

    activity = {
        {
            host = "127.0.0.1",
        },
        {
            host = "127.0.0.1",
            pwd = "1111",
        },
    },
}

RedisConf.replica = {
    default = {
        master = {
            host = "127.0.0.1",
        },
        slaves = {
            {
                host = "127.0.0.1",
            },
            {
                host = "127.0.0.1",
            },
        },
    },

    activity = {
        master = {
            host = "127.0.0.1",
        },
        slaves = {
            {
                host = "127.0.0.1",
            },
            {
                host = "127.0.0.1",
            },
        },
    },
}

return RedisConf
