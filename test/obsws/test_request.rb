require_relative "../minitest_helper"

class RequestTest < Minitest::Test
  def test_it_checks_obs_major_version
    resp = OBSWSTest.r_client.get_version
    ver = resp.obs_version.split(".").map(&:to_i)
    assert ver[0] >= 28
  end

  def test_it_checks_ws_major_version
    resp = OBSWSTest.r_client.get_version
    ver = resp.obs_web_socket_version.split(".").map(&:to_i)
    assert ver[0] >= 5
  end

  def test_it_sets_and_gets_current_program_scene
    %w[START_TEST BRB_TEST END_TEST].each do |s|
      OBSWSTest.r_client.set_current_program_scene(s)
      resp = OBSWSTest.r_client.get_current_program_scene
      assert resp.current_program_scene_name == s
    end
  end

  def test_stream_service_settings
    settings = {
      server: "rtmp://addressofrtmpserver",
      key: "live_myvery_secretkey"
    }
    OBSWSTest.r_client.set_stream_service_settings("rtmp_common", settings)
    resp = OBSWSTest.r_client.get_stream_service_settings
    assert resp.stream_service_type == "rtmp_common"
    assert resp.stream_service_settings ==
      {
        server: "rtmp://addressofrtmpserver",
        key: "live_myvery_secretkey"
      }
  end
end
