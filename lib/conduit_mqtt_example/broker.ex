defmodule ConduitMQTTExample.Broker do
  use Conduit.Broker, otp_app: :conduit_mqtt_example
  require Logger

  #  configure do
  #    queue "message", from: ["message"], exchange: "amq.topic", durable: true
  #  end

  defmodule PassThroughLogger do
    @moduledoc false
    use Conduit.Plug.Builder

    def call(message, next, _opts) do
      Logger.warn("Logger: #{inspect(message)}")
      next.(message)
    end
  end

  defmodule TestMessageReceiver do
    @moduledoc false
    use Conduit.Plug.Builder

    def call(message, next, _opts) do
      Logger.info("Broker recieved #{inspect(message)}")
      send(ConduitMQTTExampleTest, {:recieved, message})

      next.(message)
    end
  end

  pipeline :in_tracking do
    # plug Conduit.Plug.MessageId
    # plug Conduit.Plug.CorrelationId
    plug(TestMessageReceiver)
  end

  pipeline :error_handling do
    plug(Conduit.Plug.DeadLetter, broker: ConduitMQTTExample.Broker, publish_to: :error)
    plug(Conduit.Plug.Retry, attempts: 5)
  end

  pipeline :deserialize do
    plug(Conduit.Plug.Parse, content_type: "application/json")
    plug(Conduit.Plug.Unwrap)
    plug(PassThroughLogger)
  end

  incoming ConduitMQTTExample do
    pipe_through([:deserialize, :in_tracking])
    subscribe(:message, MessageSubscriber, from: "foo/bar", qos: 2)
  end

  pipeline :out_tracking do
    plug(Conduit.Plug.MessageId)
    plug(Conduit.Plug.CorrelationId)
    plug(Conduit.Plug.CreatedBy, app: "conduit_mqtt_example")
    plug(Conduit.Plug.CreatedAt)
  end

  pipeline :serialize do
    plug(Conduit.Plug.Wrap)
    plug(Conduit.Plug.Format, content_type: "application/json")
    plug(PassThroughLogger)
  end

  pipeline :error_destination do
    # FIXME:
    # plug :put_destination, &(&1.source <> ".error")
  end

  outgoing do
    pipe_through([:out_tracking, :serialize])

    publish(:message_out)
  end

  outgoing do
    pipe_through([:error_destination, :out_tracking, :serialize])

    publish(:error, exchange: "amq.topic", to: "message.error")
  end
end
