require_relative "../../lib/obsws"
require "yaml"

class Main
  def initialize(**kwargs)
    @r_client = OBSWS::Requests::Client.new(**kwargs)
    @e_client = OBSWS::Events::Client.new(**kwargs)

    @e_client.on :current_program_scene_changed do |data|
      puts "Switched to scene #{data.scene_name}"
    end
    @e_client.on :scene_created do |data|
      puts "scene #{data.scene_name} has been created"
    end
    @e_client.on :input_mute_state_changed do |data|
      puts "#{data.input_name} mute toggled"
    end
    @e_client.on :exit_started do
      puts "OBS closing!"
      @r_client.close
      @e_client.close
      @running = false
    end

    puts infostring
  end

  def infostring
    resp = @r_client.get_version
    [
      "Using obs version: #{resp.obs_version}.",
      "With websocket version: #{resp.obs_web_socket_version}"
    ].join(" ")
  end

  def run
    @running = true
    sleep(0.1) while @running
  end
end

def conn_from_yaml
  YAML.load_file("obs.yml", symbolize_names: true)[:connection]
end

Main.new(**conn_from_yaml).run if $PROGRAM_NAME == __FILE__
