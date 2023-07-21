require_relative "../../lib/obsws"
require "yaml"

OBSWS::LOGGER.info!

class Main
  def conn_from_yaml
    YAML.load_file("obs.yml", symbolize_names: true)[:connection]
  end

  def run
    OBSWS::Requests::Client.new(**conn_from_yaml).run do |client|
      resp = client.get_scene_list
      resp.scenes.reverse_each do |scene|
        puts "Switching to scene #{scene[:sceneName]}"
        client.set_current_program_scene(scene[:sceneName])
        sleep(0.5)
      end
    end
  end
end


Main.new.run if $PROGRAM_NAME == __FILE__
