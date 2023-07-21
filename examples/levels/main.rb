require_relative "../../lib/obsws"
require "yaml"

OBSWS::LOGGER.info!
DEVICE = "Desktop Audio"

module LevelTypes
  VU = 0
  POSTFADER = 1
  PREFADER = 2
end

class Main
  def initialize(**kwargs)
    subs = OBSWS::Events::SUBS::LOW_VOLUME | OBSWS::Events::SUBS::INPUTVOLUMEMETERS
    @e_client = OBSWS::Events::Client.new(subs:, **kwargs)
    @e_client.add_observer(self)
  end

  def run
    puts "press <Enter> to quit"
    exit if gets.chomp.empty?
  end

  def on_input_mute_state_changed(data)
    if data.input_name == DEVICE
      puts "#{DEVICE} mute toggled"
    end
  end

  def on_input_volume_meters(data)
    fget = ->(x) { (x > 0) ? (20 * Math.log(x, 10)).round(1) : -200.0 }

    data.inputs.each do |d|
      name = d[:inputName]
      if name == DEVICE && !d[:inputLevelsMul].empty?
        left, right = d[:inputLevelsMul]
        puts "#{name} [L: #{fget.call(left[LevelTypes::POSTFADER])}, R: #{fget.call(right[LevelTypes::POSTFADER])}]"
      end
    end
  end
end

def conn_from_yaml
  YAML.load_file("obs.yml", symbolize_names: true)[:connection]
end

Main.new(**conn_from_yaml).run if $PROGRAM_NAME == __FILE__
