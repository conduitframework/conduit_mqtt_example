defmodule ConduitMQTTExampleTest do
  use ExUnit.Case
  doctest ConduitMQTTExample

  setup do
    Process.register(self(), ConduitMQTTExampleTest)

    :ok
  end

  test "greets the world" do
    assert ConduitMQTTExample.hello() == :world
  end

  test "a sent message can be received" do
    import Conduit.Message

    ConduitMQTT.Util.wait_until(fn ->
      ConduitMQTT.Meta.get_broker_status(ConduitMQTTExample.Broker) == :up
    end)

    message =
      %Conduit.Message{}
      # topic
      |> put_destination("foo/bar")
      |> put_body("test")

    ConduitMQTTExample.Broker.publish(message, :message_out, qos: 2, retain: false, timeout: 50)

    assert_receive {:recieved, received_message}

    # topic pattern
    # TODO fix this so its not overwritten wrongly in conduit
    assert received_message.source == ["foo", "bar"]
    assert get_header(received_message, "routing_key") == "foo/bar"
    assert received_message.body == "test"
  end
end
