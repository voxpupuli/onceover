class ControlRepo_Helper

  def initialize( name )
    @name = name
    @tmp_folder = 'tmp/'
  end

  def root_folder
    return @tmp_folder + @name + '/'
  end

  def add_line_to_puppetfile( line )
    open(root_folder + 'Puppetfile', 'a') { |f| f.puts line }
  end

end
