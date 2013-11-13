require 'simplecov'
SimpleCov.start do
  add_filter "/config/"
  add_filter "/doc/"
  add_filter "/features/"
  add_filter "/reports/"
  add_filter "/spec/"
  add_filter "/test/"
  add_filter "/tmp/"

  add_group "Libraries", "lib"
  add_group "Long files" do |src_file|
    src_file.lines.count > 100
  end
  add_group "Short files" do |src_file|
    src_file.lines.count < 5
  end

  coverage_dir 'reports/coverage'
end
