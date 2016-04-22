return {
    components = {
        queue = {
            class = "framework.queue.queue",
            driver = "redis",
            name = "test_queue",
            connection = {
                host = "127.0.0.1",
                port = 6379,
                conn_timeout = 1000,
            },
            singleton = true,
        },

        countdownlatch = {
            class = "framework.concurrent.countdownlatch.countdownlatch",
            driver = "redis",
            name = "test_latch",
            value = 5,
            connection = {
                host = "127.0.0.1",
                port = 6379,
                conn_timeout = 1000,
            },
        },
    },
}
