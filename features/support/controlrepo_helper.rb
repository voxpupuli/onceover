class ControlRepo_Helper

  def initialize( name )
    @name = name
    @tmp_folder = 'tmp/'
  end

  def root_folder
    return @tmp_folder + @name + '/'
  end

end
