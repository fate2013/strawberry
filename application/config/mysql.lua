local MysqlConf = {}

MysqlConf.master = {
    host = "127.0.0.1",
    port = 3306,
    user = "root",
    password = "",
    database = "fruit",
}

MysqlConf.slaves = {
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
}

return MysqlConf
