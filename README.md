# fluentd-plugin-in-redis

> ### WARNING: This is an untested PoC at this time

Fluentd input plugin to poll events from Redis.

### Configurations

| Config            | Default | Type        | Desc |
| ----------------- | ------- | ----------- | ---- |
| `url`             | nil     | `[String]`  | Redis URL, format: `redis://:[password]@[hostname]:[port]/[db]` **REQUIRED** |
| `db`              | 0       | `[Integer]` | Database to select after initial connect |
| `timeout`         | 5.0     | `[Float]`   | Timeout in seconds |
| `key`             | nil     | `[String]`  | Redis key where events are stored **REQUIRED** |
| `tag`             | nil     | `[String]`  | If set, will assume all events are on this key and processing will be more efficent  **OPTIONAL** |
| `max_events`      | 100     | `[Integer]` | This maximum number of events to pull from redis at a time |
| `poll_interval`   | 5.0     | `[Float]`   | How often to poll Redis in seconds |

#### Example configuration

```
<match>
    @type redis

    # Redis
    url     "#{ENV['REDIS_URL']}"
    db      0
    timeout 1.0

    # Plugin
    key           messages
    max_events    100
    poll_interval 1.0

    # tag some-tag
</match>
```
