require "minitest/test_task"

HERE = __dir__

Minitest::TestTask.create(:test) do |t|
  t.libs << "test"
  t.warning = false
  t.test_globs = ["test/**/*_test.rb"]
end

task default: :test
task :events do
  filepath = File.join(HERE, "examples", "events", "main.rb")
  ruby filepath
end
task :levels do
  filepath = File.join(HERE, "examples", "events", "main.rb")
  ruby filepath
end
task :scene_rotate do
  filepath = File.join(HERE, "examples", "scene_rotate", "main.rb")
  ruby filepath
end
