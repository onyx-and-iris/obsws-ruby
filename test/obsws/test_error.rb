require_relative "../minitest_helper"

class OBSWSConnectionErrorTest < Minitest::Test
  def test_it_raises_an_obsws_connection_error_on_wrong_password
    e = assert_raises(OBSWS::OBSWSConnectionError) { OBSWS::Requests::Client.new(host: "localhost", port: 4455, password: "wrongpassword", connect_timeout: 1).new }
    assert_equal(e.message, "Timed out waiting for successful identification (1 seconds elapsed)")
  end
end

class OBSWSRequestErrorTest < Minitest::Test
  def test_it_raises_an_obsws_request_error_on_invalid_request
    e = assert_raises(OBSWS::OBSWSRequestError) { OBSWSTest.r_client.toggle_input_mute("unknown") }
    assert_equal(e.req_name, "ToggleInputMute")
    assert_equal(e.code, 600)
    assert_equal(e.message, "Request ToggleInputMute returned code 600. With message: No source was found by the name of `unknown`.")
  end
end
