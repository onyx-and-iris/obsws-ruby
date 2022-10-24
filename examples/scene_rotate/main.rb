require "obsws"
require "perfect_toml"

OBSWS::LOGGER.info!

def conn_from_toml
  PerfectTOML.load_file("obs.toml", symbolize_names: true)[:connection]
end

def main
  r_client = OBSWS::Requests::Client.new(**conn_from_toml)
  r_client.run do
    resp = r_client.get_scene_list
    resp.scenes.reverse.each do |s|
      puts "Switching to scene #{s[:sceneName]}"
      r_client.set_current_program_scene(s[:sceneName])
      sleep(0.5)
    end
  end
end

main if $0 == __FILE__
