require 'socket'
ip = Socket::getaddrinfo(Socket.gethostname,"echo",Socket::AF_INET)[0][3]

$redis = Redis.new(host: 'redis-hipache')

# initialize api.dawn.dev
redis_key = "frontend:api.#{ENV["DAWN_HOST"]}"
$redis.del(redis_key)
$redis.rpush(redis_key, "dawn")
$redis.rpush(redis_key, "#{ip}:5000")
