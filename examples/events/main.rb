require "obsws"
require "yaml"

OBSWS::LOGGER.info!

class Main
  attr_reader :running

  def initialize(**kwargs)
    @r_client = OBSWS::Requests::Client.new(**kwargs)
    @e_client = OBSWS::Events::Client.new(**kwargs)
    @e_client.add_observer(self)

    puts info.join("\n")
    @running = true
  end

  def run
    sleep(0.1) while running
  end

  def info
    resp = @r_client.get_version
    [
      "Using obs version:",
      resp.obs_version,
      "With websocket version:",
      resp.obs_web_socket_version
    ]
  end

  def on_current_program_scene_changed(data)
    puts "Switched to scene #{data.scene_name}"
  end

  def on_scene_created(data)
    puts "scene #{data.scene_name} has been created"
  end

  def on_input_mute_state_changed(data)
    puts "#{data.input_name} mute toggled"
  end

  def on_exit_started
    puts "OBS closing!"
    @r_client.close
    @e_client.close
    @running = false
  end
end

def conn_from_yaml
  YAML.load_file("obs.yml", symbolize_names: true)[:connection]
end

Main.new(**conn_from_yaml).run if $0 == __FILE__
