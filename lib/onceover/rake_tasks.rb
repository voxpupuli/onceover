require 'onceover/controlrepo'
require 'pathname'

@repo   = nil
@config = nil


desc 'Writes a `fixtures.yml` file based on the Puppetfile'
task :generate_fixtures do
  repo = Onceover::Controlrepo.new
  if File.exists?(File.expand_path('./.fixtures.yml', repo.root))
    raise ".fixtures.yml already exits, we won't overwrite because we are scared"
  end
  File.write(File.expand_path('./.fixtures.yml', repo.root), repo.fixtures)
end


desc "Modifies your `hiera.yaml` to point at the hieradata relative to its position."
task :hiera_setup do
  repo = Onceover::Controlrepo.new
  current_config = repo.hiera_config
  current_config.each do |key, value|
    if value.is_a?(Hash)
      if value.has_key?(:datadir)
        hiera_config_path = Pathname.new(File.expand_path('..', repo.hiera_config_file))
        current_config[key][:datadir] = Pathname.new(repo.hiera_data).relative_path_from(hiera_config_path).to_s
      end
    end
  end
  puts "Changing hiera config from \n#{repo.hiera_config}\nto\n#{current_config}"
  repo.hiera_config = current_config
end

task :controlrepo_details do
  require 'onceover/controlrepo'
  puts Onceover::Controlrepo.new.to_s
end

task :generate_onceover_yaml do
  require 'onceover/controlrepo'
  repo = Onceover::Controlrepo.new
  template_dir = File.expand_path('../../templates', File.dirname(__FILE__))
  onceover_yaml_template = File.read(File.expand_path('./controlrepo.yaml.erb', template_dir))
  puts ERB.new(onceover_yaml_template, nil, '-').result(binding)
end
