[![Gem Version](https://badge.fury.io/rb/obsws.svg)](https://badge.fury.io/rb/obsws)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/onyx-and-iris/obsws-ruby/blob/dev/LICENSE)
[![Ruby Code Style](https://img.shields.io/badge/code_style-standard-violet.svg)](https://github.com/standardrb/standard)

# Ruby Clients for OBS Studio WebSocket v5.0

## Requirements

- [OBS Studio](https://obsproject.com/)
- [OBS Websocket v5 Plugin](https://github.com/obsproject/obs-websocket/releases/tag/5.0.0)
  - With the release of OBS Studio version 28, Websocket plugin is included by default. But it should be manually installed for earlier versions of OBS.
- Ruby 3.0 or greater

## Installation

### Bundler

```
bundle add obsws
bundle install
```

## `Use`

#### Example `main.rb`

Pass `host`, `port` and `password` as keyword arguments.

```ruby
require "obsws"

class Main
  INPUT = "Mic/Aux"

  def run
    OBSWS::Requests::Client
      .new(host: "localhost", port: 4455, password: "strongpassword")
      .run do |client|
      # Toggle the mute state of your Mic input and print its new mute state
      client.toggle_input_mute(INPUT)
      resp = client.get_input_mute(INPUT)
      puts "Input '#{INPUT}' was set to #{resp.input_muted}"
    end
  end
end

Main.new.run if $PROGRAM_NAME == __FILE__
```

Passing OBSWS::Requests::Client.run a block closes the socket once the block returns.

### Requests

Method names for requests match the API calls but snake cased.

example:

```ruby
# GetVersion
resp = r_client.get_version

# SetCurrentProgramScene
r_client.set_current_program_scene("BRB")
```

For a full list of requests refer to [Requests](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#requests)

### Events

Register blocks with the Event client using the `on` method. Event tokens should match the event name but snake cased.

The event data will be passed to the block.

example:

```ruby
class Observer
    def initialize
        @e_client = OBSWS::Events::Client.new(host: "localhost", port: 4455, password: "strongpassword")
        # register blocks on event types.
        @e_client.on :current_program_scene_changed do |data|
          ...
        end
        @e_client.on :input_mute_state_changed do |data|
          ...
        end
    end
end
```

For a full list of events refer to [Events](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#events)

### Attributes

For both request responses and event data you may inspect the available attributes using `attrs`.

example:

```ruby
resp = cl.get_version
p resp.attrs

@e_client.on :input_mute_state_changed do |data|
  p data.attrs
end
```

### Errors

If a general error occurs an `OBSWSError` will be raised.

If a connection attempt fails or times out an `OBSWSConnectionError` will be raised.

If a request fails an `OBSWSRequestError` will be raised with a status code.

- The request name and code are retrievable through the following attributes:
  - `req_name`
  - `code`

For a full list of status codes refer to [Codes](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#requeststatus)

### Logging

To enable logs set an environmental variable `OBSWS_LOG_LEVEL` to the appropriate level.

example in powershell:

```powershell
$env:OBSWS_LOG_LEVEL="DEBUG"
```

### Tests

To run all tests:

```
bundle exec rake -v
```

### Official Documentation

For the full documentation:

- [OBS Websocket SDK](https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#obs-websocket-501-protocol)
