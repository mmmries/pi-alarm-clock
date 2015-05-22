config :logger,
        backends: [ :console, LoggerMulticastBackend ],
        level: :debug,
        format: "$time $metadata[$level] $message\n"
