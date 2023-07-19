require_relative "lib/obsws"

def main
    OBSWS::Requests::Client.new(
      host: "localhost",
      port: 4455,
      password: "strongpassword"
    ).run do |client|
      # Toggle the mute state of your Mic input
      client.toggle_input_mute("Mic/Aux")
    end
end

main if $0 == __FILE__
