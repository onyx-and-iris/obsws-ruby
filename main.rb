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
