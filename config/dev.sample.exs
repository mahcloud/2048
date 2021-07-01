use Mix.Config

# Configure your database
config :twenty, Twenty.Repo,
  username: "postgres",
  password: "postgres",
  database: "twenty_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
