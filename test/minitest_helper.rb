require "minitest"
require "minitest/autorun"
require "yaml"

require_relative "../lib/obsws"

class OBSWSTest < Minitest::Test
  class << self
    attr_reader :r_client
  end

  def self.before_run
    conn = YAML.load_file("obs.yml", symbolize_names: true)[:connection]
    @r_client = OBSWS::Requests::Client.new(**conn)

    r_client.create_scene("START_TEST")
    r_client.create_scene("BRB_TEST")
    r_client.create_scene("END_TEST")
  end

  before_run

  def setup
  end

  def teardown
  end

  Minitest.after_run do
    r_client.remove_scene("START_TEST")
    r_client.remove_scene("BRB_TEST")
    r_client.remove_scene("END_TEST")
    r_client.close
  end
end
