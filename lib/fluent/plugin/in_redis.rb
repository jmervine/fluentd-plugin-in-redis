# coding: utf-8
require 'fluent/input'

class Fluent::RedisInInput < Fluent::Input
  Fluent::Plugin.register_input('redis', self)

  unless method_defined?(:log)
    define_method('log') { $log }
  end

  unless method_defined?(:router)
    define_method('router') { Fluent::Engine }
  end

  # Redis configurations.
  config_param :url, :string  # REQUIRED
    # format --> redis://:[password]@[hostname]:[port]/[db]
  config_param :db, :integer, default: 0
  config_param :timeout, :float, default: 5.0

  # TODO: Support other redis-rb configuration options as needed, see:
  #  https://www.rubydoc.info/github/redis/redis-rb/Redis:initialize

  # Plugin configurations.
  config_param :key, :string # REQUIRED
  config_param :tag, :string, default: nil # If undefined, multi tag support will be enabled.
  config_param :max_events, :integer, default: 100
  config_param :poll_interval, :float, default: 5.0 # seconds

  def initialize
    super

    require 'redis'
  end

  # `configure` is called before `start`.
  def configure(conf)
    super

    # Non-redis configurations
    @key = conf["key"]
    @max = conf["max_events"]
    @int = conf["poll_interval"]
    @tag = conf["tag"]

    # redis configuration
    @redis_conf = {}
    [:url, :timeout, :connect_timeout, :id ].each do |key|
      @redis_conf[key] = conf[key.to_s]
    end
  end

  # `start` is called when starting and after `configure` is successfully completed.
  def start
    super

    @redis = Redis.new(@redis_conf)
    #raise Fluent::ConfigError, "failed to connect to redis source." unless @redis.connected?

    # Async processor
    @loop = Coolio::Loop.new

    meth  = @tag.nil? ? :handler : :mult_handler
    timer = TimerWatcher.new(@int, true, log, &method(meth))

    @loop.attach(timer)
    @thread = Thread.new(&method(:run))
  end

  # `shutdown` is called while closing down.
  def shutdown
    #@running = false

    @loop.watchers.each {|w| w.detach}
    @loop.stop

    super
  end

  protected
  def run
    @loop.run
  rescue => e
    log.error(e.message)
    log.error_backtrace(e.backtrace)
  end

  # This is more efficent
  def handler
    records = @redis.rpop(@key, @max)

    stream = MultiEventStream.new
    records.each do |record|
      record.delete("@tag")
      time = record.delete("@time")

      stream.add(time, record)
    end
    router.emit_stream(@tag, stream)
  end

  # This is more flexible to real world use
  def multi_handler
    records = @redis.rpop(@key, @max)

    streams = {}
    records.each do |record|
      tag  = record.delete("@tag")
      time = record.delete("@time")

      streams[tag] = MultiEventStream.new unless streams.has_key?(tag)

      streams[tag].add(time, record)
    end

    records.each do |tag, stream|
      router.emit_stream(tag, stream)
    end
  end

  class TimerWatcher < Coolio::TimerWatcher
    def initialize(interval, repeat, log, &callback)
      @callback = callback
      @log = log
      super(interval, repeat)
    end

    def on_timer
      @callback.call
    rescue => e
      @log.error(e.message)
      @log.error_backtrace(e.backtrace)
    end
  end # TimerWatcher
end

