require "obsws"
require "yaml"

OBSWS::LOGGER.info!

def conn_from_yaml
  YAML.load_file("obs.yml", symbolize_names: true)[:connection]
end

def main
  OBSWS::Requests::Client.new(**conn_from_yaml).run do |client|
    resp = client.get_scene_list
    resp.scenes.reverse_each do |scene|
      puts "Switching to scene #{scene[:sceneName]}"
      client.set_current_program_scene(scene[:sceneName])
      sleep(0.5)
    end
  end
end

main if $0 == __FILE__
