namespace :release do
  desc "Bumps the version"
  task :bump, :version do |t, args|
    VERSION_REGEXP = /\d+\.\d+\.\d+.*/
    USAGE = <<-EOF
=========
= Usage =
=========

rake release:bump[X.X.X]

This will bump an existing version file to the specified version and commit the change.
It also creates and pushes a new tag in the form "vX.X.X".
Please omit any "v" prefix.
EOF

    if !args[:version]
      puts "Error: Please provide a new version"
      puts USAGE
      exit 1
    elsif !(args[:version] =~ VERSION_REGEXP)
      puts "Error: Please provide a new version number in the form X.X.X"
      puts USAGE
      exit 1
    end

    file_name = Rails.root.join("lib", "iqvoc", "auto_classify", "version.rb")
    version_file = File.read(file_name)
    new_version_file = version_file.gsub(/["']#{VERSION_REGEXP}["']/, "'#{args[:version]}'")

    File.open(file_name, "w") { |file| file.puts new_version_file }

    system "git add #{file_name.relative_path_from(Rails.root)}"
    system "git commit -m \"v#{args[:version]}\""
    system "git tag v#{args[:version]} -am \"v#{args[:version]}\""
    system "gem build #{gemspec}"
  end

  desc "Bumps and pushes the version"
  task :push, [:version] => :bump do
    system "git push origin master --tags"
    system "iq_gem --gemspec #{gemspec} --tag v#{args[:version]} --gem-repo iqvoc"
  end

  def gemspec
    Rails.root.join("iqvoc_autoclassify.gemspec")
  end
end
