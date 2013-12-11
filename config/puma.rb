on_worker_boot do
  $redis.client.reconnect
end
