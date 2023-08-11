require "minitest/test_task"

HERE = __dir__

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.warning = false
  t.test_globs = ["test/**/test_*.rb"]
end

task default: :test

namespace :e do
  desc "Runs the events example"
  task :events do
    filepath = File.join(HERE, "examples", "events", "main.rb")
    ruby filepath
  end
  desc "Runs the levels example"
  task :levels do
    filepath = File.join(HERE, "examples", "levels", "main.rb")
    ruby filepath
  end
  desc "Runs the scene_rotate example"
  task :scene_rotate do
    filepath = File.join(HERE, "examples", "scene_rotate", "main.rb")
    ruby filepath
  end
end
