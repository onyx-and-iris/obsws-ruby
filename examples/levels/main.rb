require_relative "../../lib/obsws"
require "yaml"

module LevelTypes
  VU = 0
  POSTFADER = 1
  PREFADER = 2
end

class Main
  DEVICE = "Desktop Audio"

  def initialize(**kwargs)
    subs = OBSWS::Events::SUBS::LOW_VOLUME | OBSWS::Events::SUBS::INPUTVOLUMEMETERS
    @e_client = OBSWS::Events::Client.new(subs:, **kwargs)

    @e_client.on(:input_mute_state_changed) do |data|
      if data.input_name == DEVICE
        puts "#{DEVICE} mute toggled"
      end
    end
    @e_client.on(:input_volume_meters) do |data|
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

  def run
    puts "press <Enter> to quit"
    loop { break if gets.chomp.empty? }
  end
end

def conn_from_yaml
  YAML.load_file("obs.yml", symbolize_names: true)[:connection]
end

Main.new(**conn_from_yaml).run if $PROGRAM_NAME == __FILE__
