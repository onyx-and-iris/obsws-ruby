require_relative "lib/obsws"

class Main
  def run
    OBSWS::Requests::Client.new(
      host: "localhost",
      port: 4455,
      password: "strongpassword"
    ).run do |client|
      # Toggle the mute state of your Mic input
      client.toggle_input_mute("Mic/Aux")
    end
  end
end

Main.new.run if $PROGRAM_NAME == __FILE__
