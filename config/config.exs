# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :conduit_mqtt_example, ConduitMQTTExample.Broker,
  adapter: ConduitMQTT,
  connection_opts: [server: {Tortoise.Transport.Tcp, host: 'localhost', port: 1883}],
  ignore_needs_wrapping: true
