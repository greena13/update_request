guard :rspec, cmd: 'bundle exec rspec' do
  last_run_spec = nil

  watch(%r{^app/(.+)\.rb$}) do |match|
    file_path = "spec/#{match[1]}"

    last_run_spec =
      if Dir.exists?(file_path)
        Dir["#{File.dirname(file_path)}/**/*_spec.rb"]
      else
        last_run_spec
      end
  end

  watch(%r{^spec/(.+)_spec\.rb$}) do |match|
    last_run_spec = "spec/#{match[1]}_spec.rb"
  end

  watch(%r{^spec/dummy/.+\.rb$}) do
    last_run_spec
  end
end
