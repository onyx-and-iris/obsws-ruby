require_relative "../minitest_helper"

class OBSWSConnectionErrorTest < Minitest::Test
  def test_it_raises_an_obsws_connection_error_on_wrong_password
    e = assert_raises(OBSWS::OBSWSConnectionError) do
      OBSWS::Requests::Client
        .new(host: "localhost", port: 4455, password: "wrongpassword", connect_timeout: 0.1)
    end
    assert_equal("Timed out waiting for successful identification (0.1 seconds elapsed)", e.message)
  end

  def test_it_raises_an_obsws_connection_error_on_auth_enabled_but_no_password_provided_for_request_client
    e = assert_raises(OBSWS::OBSWSConnectionError) do
      OBSWS::Requests::Client
        .new(host: "localhost", port: 4455, password: "")
    end
    assert_equal("auth enabled but no password provided", e.message)
  end

  def test_it_raises_an_obsws_connection_error_on_auth_enabled_but_no_password_provided_for_event_client
    e = assert_raises(OBSWS::OBSWSConnectionError) do
      OBSWS::Events::Client
        .new(host: "localhost", port: 4455, password: "")
    end
    assert_equal("auth enabled but no password provided", e.message)
  end
end

class OBSWSRequestErrorTest < Minitest::Test
  def test_it_raises_an_obsws_request_error_on_invalid_request
    e = assert_raises(OBSWS::OBSWSRequestError) { OBSWSTest.r_client.toggle_input_mute("unknown") }
    assert_equal("ToggleInputMute", e.req_name)
    assert_equal(600, e.code)
    assert_equal("Request ToggleInputMute returned code 600. With message: No source was found by the name of `unknown`.", e.message)
  end
end
