class ControlRepo_Helper

  attr_reader :tmp_folder

  def initialize( name )
    @name       = name
    @tmp_folder = '.cucumber/tmp/'
  end

  def root_folder
    return @tmp_folder + @name + '/'
  end

  def puppetfile
    return root_folder + "Puppetfile"
  end

  def onceover_temp_root_folder
    return root_folder + '.onceover/etc/puppetlabs/code/environments/production/'
  end

  def onceover_temp_puppetfile
    return onceover_temp_root_folder + "Puppetfile"
  end

  def add_line_to_puppetfile( line )
    open(puppetfile, 'a') { |f| f.puts line }
  end

end
