require 'helper'
require 'fluent/test/driver/input'
require 'fluent/plugin/in_redis'

class RedisInInputTest  < Test::Unit::TestCase
  BASE_CONFIG = %[
    url redis://localhost
    key test
  ]

  def setup
    Fluent::Test.setup

    @time = Fluent::Engine.now
  end

  def create_driver(config = BASE_CONFIG)
    Fluent::Test::Driver::Input.new(Fluent::RedisInInput).configure(config)
  end

  def test_configure_required
    assert_raise Fluent::ConfigError do
      create_driver('')
    end
  end

  def test_reading_from_redis_with_tag
    events = [ { "@tag" => "tag", "@time" => @time, "message" => "message" } ]

    # Mock Redis#rpop
    Redis.send(:define_method, :rpop, proc { |_,_| return events })

    d = create_driver(BASE_CONFIG + "tag test\n")
    d.run(expect_records: events.size, timeout: 5)

    es = d.event_streams.first

    assert_equal("test", es.first)
    assert_equal(
      [[ @time, { "message" => "message" } ]],
      es[1].to_a
    )
  end

  def test_reading_from_redis_without_tag
    events = [
      { "@tag" => "tag1", "@time" => @time, "message" => "message" },
      { "@tag" => "tag2", "@time" => @time, "message" => "message" }
    ]

    # Mock Redis#rpop
    Redis.send(:define_method, :rpop, proc { |_,_| return events })

    d = create_driver
    d.run(expect_records: events.size, timeout: 5)

    assert_equal(2, d.event_streams.size)

    ["tag1","tag2"].each do |tag|
      es = d.event_streams(tag: tag).first

      assert_equal(tag, es.first)
      assert_equal(
        [[ @time, { "message" => "message" } ]],
        es[1].to_a
      )
    end
  end
end
