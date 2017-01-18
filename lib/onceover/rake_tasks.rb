require 'onceover/controlrepo'
require 'pathname'

@repo = nil
@config = nil


desc 'Writes a `fixtures.yml` file based on the Puppetfile'
task :generate_fixtures do
  repo = Onceover::Controlrepo.new
  raise ".fixtures.yml already exits, we won't overwrite because we are scared" if File.exists?(File.expand_path('./.fixtures.yml',repo.root))
  File.write(File.expand_path('./.fixtures.yml',repo.root),repo.fixtures)
end


desc "Modifies your `hiera.yaml` to point at the hieradata relative to its position."
task :hiera_setup do
  repo = Onceover::Controlrepo.new
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
  require 'onceover/controlrepo'
  puts Onceover::Controlrepo.new.to_s
end

task :generate_onceover_yaml do
  require 'onceover/controlrepo'
  repo = Onceover::Controlrepo.new
  template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
  onceover_yaml_template = File.read(File.expand_path('./controlrepo.yaml.erb',template_dir))
  puts ERB.new(onceover_yaml_template, nil, '-').result(binding)
end


task :generate_nodesets do
  require 'onceover/beaker'
  require 'net/http'
  require 'json'

  repo = Onceover::Controlrepo.new

  puts "HOSTS:"

  repo.facts.each do |fact_set|
    node_name = File.basename(repo.facts_files[repo.facts.index(fact_set)],'.json')
    boxname = Onceover::Beaker.facts_to_vagrant_box(fact_set)
    platform = Onceover::Beaker.facts_to_platform(fact_set)

    uri = URI("https://atlas.hashicorp.com:443/api/v1/box/#{boxname}")
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = true
    response = request.get(uri)

    url = 'URL goes here'

    if response.code == "404"
      comment_out = true
    else
      comment_out = false
      box_info = JSON.parse(response.body)
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
  require 'onceover/testconfig'
  require 'onceover/runner'
  @repo = Onceover::Controlrepo.new
  # TODO: This should be getting the location of controlrepo.yaml from @repo
  @config = Onceover::TestConfig.new("#{@repo.spec_dir}/controlrepo.yaml")

  @runner = Onceover::Runner.new(@repo, @config)
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
  require 'onceover/testconfig'
  repo = Onceover::Controlrepo.new
  config = Onceover::TestConfig.new("#{repo.spec_dir}/controlrepo.yaml")
  FileUtils.rm_rf(repo.tempdir)
  # Deploy r10k to a temp dir
  config.r10k_deploy_local(repo)
end
