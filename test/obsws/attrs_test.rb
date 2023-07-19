require_relative "../minitest_helper"

class AttrsTest < OBSWSTest
  def test_get_version_attrs
    resp = OBSWSTest.r_client.get_version
    assert resp.attrs ==
      %w[
        available_requests
        obs_version
        obs_web_socket_version
        platform
        platform_description
        rpc_version
        supported_image_formats
      ]
  end
end
