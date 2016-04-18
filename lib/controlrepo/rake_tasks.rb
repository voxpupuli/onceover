require 'controlrepo'
require 'pathname'

@repo = nil
@config = nil

task :generate_fixtures do
  repo = Controlrepo.new
  raise ".fixtures.yml already exits, we won't overwrite because we are scared" if File.exists?(File.expand_path('./.fixtures.yml',repo.root))
  File.write(File.expand_path('./.fixtures.yml',repo.root),repo.fixtures)
end

task :hiera_setup do
  repo = Controlrepo.new
  current_config = repo.hiera_config
  current_config.each do |key, value|
    if value.is_a?(Hash)
      if value.has_key?(:datadir)
        current_config[key][:datadir] = Pathname.new(repo.hiera_data).relative_path_from(Pathname.new(File.expand_path('..',repo.hiera_config_file))).to_s
      end
    end
  end
  puts "Changing hiera config from \n#{repo.hiera_config}\nto\n#{current_config}"
  repo.hiera_config = current_config
end

task :controlrepo_details do
  require 'controlrepo'
  puts Controlrepo.new.to_s
end

task :generate_controlrepo_yaml do
  require 'controlrepo'
  repo = Controlrepo.new
  template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
  controlrepo_yaml_template = File.read(File.expand_path('./controlrepo.yaml.erb',template_dir))
  puts ERB.new(controlrepo_yaml_template, nil, '-').result(binding)
end


task :generate_nodesets do
  require 'controlrepo/beaker'
  require 'net/http'
  require 'json'

  repo = Controlrepo.new

  puts "HOSTS:"

  repo.facts.each do |fact_set|
    node_name = File.basename(repo.facts_files[repo.facts.index(fact_set)],'.json')
    boxname = Controlrepo::Beaker.facts_to_vagrant_box(fact_set)
    platform = Controlrepo::Beaker.facts_to_platform(fact_set)
    response = Net::HTTP.get(URI.parse("https://atlas.hashicorp.com/api/v1/box/#{boxname}"))
    url = 'URL goes here'

    if response =~ /Not Found/i
      comment_out = true
    else
      comment_out = false
      box_info = JSON.parse(response)
      box_info['current_version']['providers'].each do |provider|
        if  provider['name'] == 'virtualbox'
          url = provider['original_url']
        end
      end
    end

    # Use an ERB template
    template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
    fixtures_template = File.read(File.expand_path('./nodeset.yaml.erb',template_dir))
    puts ERB.new(fixtures_template, nil, '-').result(binding)
  end

end

task :controlrepo_autotest_prep do
  require 'controlrepo/testconfig'
  require 'controlrepo/runner'
  @repo = Controlrepo.new
  # TODO: This should be getting the location of controlrepo.yaml from @repo
  @config = Controlrepo::TestConfig.new("#{@repo.spec_dir}/controlrepo.yaml")

  @runner = Controlrepo::Runner.new(@repo, @config)
  @runner.prepare!
end

task :controlrepo_autotest_spec do
  @runner.run_spec!
end

task :controlrepo_autotest_acceptance do
  @runner.run_acceptance!
end

task :controlrepo_spec => [
  :controlrepo_autotest_prep,
  :controlrepo_autotest_spec
  ]

task :controlrepo_acceptance => [
  :controlrepo_autotest_prep,
  :controlrepo_autotest_acceptance
  ]

task :controlrepo_temp_create do
  require 'controlrepo/testconfig'
  repo = Controlrepo.new
  config = Controlrepo::TestConfig.new("#{repo.spec_dir}/controlrepo.yaml")
  FileUtils.rm_rf(repo.tempdir)
  # Deploy r10k to a temp dir
  config.r10k_deploy_local(repo)
end
