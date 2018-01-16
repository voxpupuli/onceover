require 'pathname'

class Cache_Helper
  def self.class_to_path(cls)
    segments                = cls.split('::')
    module_name             = segments[0]
    class_name              = segments[-1]
    folders_under_manifests = segments[1..-2] if segments.count > 2
    [module_name,'manifests',folders_under_manifests,"#{class_name}.pp"].flatten.join('/')
  end

  def self.digest(path, opts = {
    exceptions: ['.','..','.onceover']
    })
    if File.directory?(path)
      # Get the list of files
      children = Cache_Helper.get_children(path, opts[:exceptions])
    else
      children = [File.expand_path(path)]
    end

    # Calculate hashes
    hashes = children.map do |child_path|
      if File.directory? child_path
        :directory
      else
        Digest::MD5.file(child_path)
      end
    end

    root = Pathname.new(File.expand_path(path))
    # Move pathnames back to relative
    children.map! do |child_path|
      Pathname.new(child_path).relative_path_from root
    end
    Hash[children.zip(hashes)]
  end

  def self.get_children(dir, exclusions)
    root_files = []
    files      = []
    Dir.chdir(dir) do
      # Get all root files
      root_files = Dir.glob('*',File::FNM_DOTMATCH)
      root_files = root_files - exclusions
      root_files.each do |file|
        files << file
        files << Dir.glob("#{file}/**/*",File::FNM_DOTMATCH)
      end
      files.flatten!
      # Calculate absolue paths
      files.map! do |file|
        File.expand_path(file)
      end
    end
    files
  end
end
