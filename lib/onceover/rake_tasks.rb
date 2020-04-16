require 'onceover/controlrepo'
require 'pathname'

@repo   = nil
@config = nil


desc 'Writes a `fixtures.yml` file based on the Puppetfile'
task :generate_fixtures do
  repo = Onceover::Controlrepo.new
  if File.exist?(File.expand_path('./.fixtures.yml', repo.root))
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


task :generate_nodesets do
  warn "[DEPRECATION] #{__method__} is deprecated due to the removal of Beaker"

  require 'onceover/beaker'
  require 'net/http'
  require 'multi_json'

  repo = Onceover::Controlrepo.new

  puts "HOSTS:"

  repo.facts.each do |fact_set|
    node_name = File.basename(repo.facts_files[repo.facts.index(fact_set)], '.json')
    boxname   = Onceover::Beaker.facts_to_vagrant_box(fact_set)
    platform  = Onceover::Beaker.facts_to_platform(fact_set)

    uri = URI("https://atlas.hashicorp.com:443/api/v1/box/#{boxname}")
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = true
    response = request.get(uri)

    url = 'URL goes here'

    if response.code == "404"
      comment_out = true
    else
      comment_out = false
      box_info = MultiJson.load(response.body)
      box_info['current_version']['providers'].each do |provider|
        if  provider['name'] == 'virtualbox'
          url = provider['original_url']
        end
      end
    end

    # Use an ERB template
    template_dir = File.expand_path('../../templates', File.dirname(__FILE__))
    fixtures_template = File.read(File.expand_path('./nodeset.yaml.erb', template_dir))
    puts ERB.new(fixtures_template, nil, '-').result(binding)
  end

end
