require "obsws"
require "perfect_toml"

OBSWS::LOGGER.info!
DEVICE = "Desktop Audio"

module LevelTypes
  VU = 0
  POSTFADER = 1
  PREFADER = 2
end

class Observer
  attr_reader :running

  def initialize(**kwargs)
    kwargs[:subs] = OBSWS::Events::SUBS::LOW_VOLUME | OBSWS::Events::SUBS::INPUTVOLUMEMETERS
    @e_client = OBSWS::Events::Client.new(**kwargs)
    @e_client.add_observer(self)
  end
  
  def on_input_mute_state_changed(data)
    """An input's mute state has changed."""
    if data.input_name == DEVICE
      puts "#{DEVICE} mute toggled"
    end
  end

  def on_input_volume_meters(data)
    def fget(x) = x > 0 ? (20 * Math.log(x, 10)).round(1) : -200.0

    data.inputs.each do |d|
      name = d[:inputName]
      if name == DEVICE && !d[:inputLevelsMul].empty?
        left, right = d[:inputLevelsMul]
        puts "#{name} [L: #{fget(left[LevelTypes::POSTFADER])}, R: #{fget(right[LevelTypes::POSTFADER])}]"
      end
    end
  end
end

def conn_from_toml
  PerfectTOML.load_file("obs.toml", symbolize_names: true)[:connection]
end

def main
  o = Observer.new(**conn_from_toml)

  puts "press <Enter> to quit"
  loop { exit if gets.chomp.empty? }
end

main if $0 == __FILE__
