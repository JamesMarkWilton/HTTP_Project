task default: :test
task default: :cop

desc "Run my Tests!"
task :test do
  sh "bundle exec mrspec"
end

desc "Run RuboCop!"
task :cop do
  sh "bundle exec rubocop --fail-fast"
end
