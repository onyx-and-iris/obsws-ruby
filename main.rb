require_relative "lib/obsws"

def main
  r_client =
    OBSWS::Requests::Client.new(
      host: "localhost",
      port: 4455,
      password: "strongpassword"
    )

  r_client.run do
    # Toggle the mute state of your Mic input
    r_client.toggle_input_mute("Mic/Aux")
  end
end

main if $0 == __FILE__
