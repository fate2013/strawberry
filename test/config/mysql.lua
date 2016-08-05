local MysqlConf = {}

MysqlConf = {
    default = {
        master = {
            host = "127.0.0.1",
            port = 3306,
            user = "root",
            password = "",
            database = "fruit",
            conn_timeout = 5000,
        },
        slaves = {
            {
                host = "127.0.0.1",
                user = "root",
                password = "",
                database = "fruit",
                conn_timeout = 5000,
            },
            {
                host = "127.0.0.1",
                user = "root",
                password = "",
                database = "fruit",
                conn_timeout = 5000,
            },
        },
    },
    activity = {
        master = {
            host = "127.0.0.1",
            port = 3306,
            user = "root",
            password = "",
            database = "fruit",
        },
        slaves = {
            {
                host = "127.0.0.1",
                user = "root",
                password = "",
                database = "fruit",
            },
            {
                host = "127.0.0.1",
                user = "root",
                password = "",
                database = "fruit",
            },
        },
    },
}

return MysqlConf
