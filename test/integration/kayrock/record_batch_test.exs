defmodule KafkaEx.KayrockRecordBatchTest do
  @moduledoc """
  Tests for producing/fetching messages using the newer RecordBatch format
  """

  use ExUnit.Case

  alias KafkaEx.New.Client

  @moduletag :new_client

  setup do
    {:ok, args} = KafkaEx.build_worker_options([])

    {:ok, pid} = Client.start_link(args, :no_name)

    {:ok, %{client: pid}}
  end

  test "can specify protocol version for fetch - v3", %{client: client} do
    topic = "food"
    msg = TestHelper.generate_random_string()

    {:ok, offset} =
      KafkaEx.produce(
        topic,
        0,
        msg,
        worker_name: client,
        required_acks: 1
      )

    fetch_responses =
      KafkaEx.fetch(topic, 0,
        offset: 0,
        auto_commit: false,
        worker_name: client,
        protocol_version: 3
      )

    [fetch_response | _] = fetch_responses
    [partition_response | _] = fetch_response.partitions
    message = List.last(partition_response.message_set)

    assert message.value == msg
    assert message.offset == offset
  end

  test "empty message set - v3", %{client: client} do
    topic = "food"
    msg = TestHelper.generate_random_string()

    {:ok, offset} =
      KafkaEx.produce(
        topic,
        0,
        msg,
        worker_name: client,
        required_acks: 1
      )

    fetch_responses =
      KafkaEx.fetch(topic, 0,
        offset: offset + 5,
        auto_commit: false,
        worker_name: client,
        protocol_version: 3
      )

    [fetch_response | _] = fetch_responses
    [partition_response | _] = fetch_response.partitions
    assert partition_response.message_set == []
  end

  test "can specify protocol version for fetch - v5", %{client: client} do
    topic = "food"
    msg = TestHelper.generate_random_string()

    {:ok, offset} =
      KafkaEx.produce(
        topic,
        0,
        msg,
        worker_name: client,
        required_acks: 1
      )

    fetch_responses =
      KafkaEx.fetch(topic, 0,
        offset: 0,
        auto_commit: false,
        worker_name: client,
        protocol_version: 5
      )

    [fetch_response | _] = fetch_responses
    [partition_response | _] = fetch_response.partitions
    message = List.last(partition_response.message_set)

    assert message.offset == offset
    assert message.value == msg
  end

  test "empty message set - v5", %{client: client} do
    topic = "food"
    msg = TestHelper.generate_random_string()

    {:ok, offset} =
      KafkaEx.produce(
        topic,
        0,
        msg,
        worker_name: client,
        required_acks: 1
      )

    fetch_responses =
      KafkaEx.fetch(topic, 0,
        offset: offset + 5,
        auto_commit: false,
        worker_name: client,
        protocol_version: 5
      )

    [fetch_response | _] = fetch_responses
    [partition_response | _] = fetch_response.partitions
    assert partition_response.message_set == []
  end
end
