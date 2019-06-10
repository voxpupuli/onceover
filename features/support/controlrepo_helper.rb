class ControlRepo_Helper

  attr_reader :tmp_folder

  def initialize( name )
    @name       = name
    @tmp_folder = '.cucumber/tmp/'
  end

  def root_folder
    @tmp_folder + @name + '/'
  end

  def puppetfile
    root_folder + "Puppetfile"
  end

  def onceover_temp_root_folder
    root_folder + '.onceover/etc/puppetlabs/code/environments/production/'
  end

  def onceover_temp_puppetfile
    onceover_temp_root_folder + "Puppetfile"
  end

  def config_file
    root_folder + 'spec/onceover.yaml'
  end

  def config_file_contents
    File.read(config_file)
  end

  def add_line_to_puppetfile( line )
    open(puppetfile, 'a') { |f| f.puts line }
  end

end
