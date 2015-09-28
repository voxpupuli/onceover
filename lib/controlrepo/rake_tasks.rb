require 'controlrepo'
require 'pathname'

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

task :generate_nodesets do
  require 'controlrepo/beaker'
  require 'net/http'
  require 'json'

  repo = Controlrepo.new

  begin
    Dir.mkdir("#{repo.root}/spec/acceptance")
    puts "Created #{repo.root}/spec/acceptance"
    Dir.mkdir("#{repo.root}/spec/acceptance/nodesets")
    puts "Created #{repo.root}/spec/acceptance/nodesets"
  rescue Errno::EEXIST
    # Do nothing, this is okay
  end

  facts = repo.facts
  facts.each do |fact_set|
    boxname = Controlrepo_beaker.facts_to_vagrant_box(fact_set)
    box_info = JSON.parse(Net::HTTP.get(URI.parse("https://atlas.hashicorp.com/api/v1/box/#{boxname}")))
    url = 'URL goes here'
    box_info['current_version']['providers'].each do |provider|
      if provider['name'] == 'virtualbox'
        url = provider['original_url']
      end
    end
    # Use an ERB template to write the files
    template_dir = File.expand_path('../../templates',File.dirname(__FILE__))
    fixtures_template = File.read(File.expand_path('./nodeset.yaml.erb',template_dir))
    output_file = File.expand_path("spec/acceptance/nodesets/#{fact_set['fqdn']}.yaml",repo.root)
    if File.exists?(output_file) == false
      File.write(output_file,ERB.new(fixtures_template, nil, '-').result(binding))
      puts "Created #{output_file}"
    else
      puts "#{output_file} already exists, not going to overwrite because scared"
    end
  end
end