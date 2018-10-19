# ConduitMQTTExample

Example App that uses [Conduit](https://github.com/conduitframework/conduit) and [ConduitAMQP](https://github.com/conduitframework/conduit_amqp).

## Running

You'll need a RabbitMQ running locally. This project expects the default RabbitMQ user `guest` with password `guest` and
the default port `5672`. An easy way to do that is using docker, like so:

``` bash
docker run -p 1883:1883 -e "DOCKER_VERNEMQ_ALLOW_ANONYMOUS=on" -e "DOCKER_VERNEMQ_log.console.level=debug" -it erlio/docker-vernemq:1.5.0
```

You can run the project by doing:

``` bash
iex -S mix run
```

You should see logs mentioning that it has created the `message` queue at startup.

```
22:28:46.712 [info]  MQTT Adapter started!
```

Once you have an iex prompt, you can send a message by doing:

``` elixir
import Conduit.Message
alias Conduit.Message
alias ConduitMQTTExample.Broker

message = put_body(%Message{}, %{"my" => "message"})

Broker.publish(:message_out, message)
```
