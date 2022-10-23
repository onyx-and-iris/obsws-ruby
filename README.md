[![Gem Version](https://badge.fury.io/rb/obsws.svg)](https://badge.fury.io/rb/obsws)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/onyx-and-iris/voicemeeter-api-ruby/blob/dev/LICENSE)
[![code style: prettier](https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat-square)](https://github.com/prettier/plugin-ruby)

# A Ruby wrapper around OBS Studio WebSocket v5.0

## Requirements

-   [OBS Studio](https://obsproject.com/)
-   [OBS Websocket v5 Plugin](https://github.com/obsproject/obs-websocket/releases/tag/5.0.0)
    -   With the release of OBS Studio version 28, Websocket plugin is included by default. But it should be manually installed for earlier versions of OBS.
-   Ruby 3.0 or greater

## `Use`

#### Example `main.rb`

pass `host`, `port` and `password` as keyword arguments.

```ruby
require "obsws"

def main
  r_client =
    OBSWS::Requests::Client.new(
      host: "localhost",
      port: 4455,
      password: "strongpassword"
    )

  r_client.run do
    # Toggle the mute state of your Mic input
    r_client.toggle_input_mute("Mic/Aux")
  end
end

main if $0 == __FILE__
```

### Requests

Method names for requests match the API calls but snake cased. `run` accepts a block that closes the socket once you are done.

example:

```ruby
r_client.run do
  # GetVersion
  resp = r_client.get_version

  # SetCurrentProgramScene
  r_client.set_current_program_scene("BRB")
end
```

For a full list of requests refer to [Requests](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#requests)

### Events

Register an observer class and define `on_` methods for events. Method names should match the api event but snake cased.

example:

```ruby
class Observer
    def initialize
        @e_client = OBSWS::Events::Client.new(**kwargs)
        # register class with the event client
        @e_client.add_observer(self)
    end

    # define "on_" event methods.
    def on_current_program_scene_changed
        ...
    end
    def on_input_mute_state_changed
        ...
    end
    ...
end
```

For a full list of events refer to [Events](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#events)

### Attributes

For both request responses and event data you may inspect the available attributes using `attrs`.

example:

```ruby
resp = cl.get_version
p resp.attrs

def on_scene_created(data):
    p data.attrs
```

### Errors

If a request fails an `OBSWSError` will be raised with a status code.

For a full list of status codes refer to [Codes](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#requeststatus)

### Tests

To run all tests:

```
bundle exec rake -v
```

### Official Documentation

For the full documentation:

-   [OBS Websocket SDK](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#obs-websocket-501-protocol)
