require 'puppet/version'
require 'net/http'
require 'uri'
require 'multi_json'
require 'r10k/module_loader/puppetfile'
require 'onceover/logger'

### operations
#
# 1. resolve all the component json files in the puppet-agent repo for vendored modules
# 2. parse each json file and determine vendored modules repo + ref
#
###

## Example
#
# vm = Onceover::VendoredModules.new
# puts vm.vendored_references
# puppetfile = R10K::ModuleLoader::Puppetfile.new(basedir: '.')
# vm.puppetfile_missing_vendored(puppetfile)
# puts vm.missing_vendored.inspect

class Onceover
  class VendoredModules
    attr_reader :vendored_references, :missing_vendored

    def initialize(opts = {})
      @repo = opts[:repo] || Onceover::Controlrepo.new
      @cachedir = opts[:cachedir] || File.join(@repo.tempdir, 'vendored_modules')
      @puppet_version = Gem::Version.new(Puppet.version)
      @puppet_major_version = Gem::Version.new(@puppet_version.segments[0])
      @force_update = opts[:force_update] || false

      @missing_vendored = []

      # This only applies to puppet >= 6 so bail early
      raise 'Auto resolving vendored modules only applies to puppet versions >= 6' unless @puppet_major_version >= Gem::Version.new('6')

      # Create cachedir
      unless File.directory?(@cachedir)
        logger.debug "Creating #{@cachedir}"
        FileUtils.mkdir_p(@cachedir)
      end

      # Location of user provided caches:
      #   control-repo/spec/vendored_modules/<component>-puppet_agent-<agent version>.json
      @manual_vendored_dir = File.join(@repo.spec_dir, 'vendored_modules')

      # Get the entire file tree of the puppetlabs/puppet-agent repository
      # https://docs.github.com/en/rest/git/trees?apiVersion=2022-11-28#get-a-tree
      puppet_agent_tree = query_or_cache(
        "https://api.github.com/repos/OpenVoxProject/openvox/git/trees/#{@puppet_version}",
        { recursive: true },
        component_cache('repo_tree'),
      )
      # Get only the module-puppetlabs-<something>_core.json component files
      vendored_components =  puppet_agent_tree['tree'].select { |file| %r{packaging/configs/components/module-puppetlabs-\w+\.json}.match(file['path']) }
      # Get the contents of each component file
      # https://docs.github.com/en/rest/git/blobs?apiVersion=2022-11-28#get-a-blob
      @vendored_references = vendored_components.map do |component|
        mod_slug = component['path'].match(/.*(puppetlabs-\w+).json$/)[1]
        mod_name = mod_slug.match(/puppetlabs-(\w+)/)[1]
        query_or_cache(
          component['url'],
          nil,
          component_cache(mod_name),
        )
      end
    end

    def component_cache(component)
      # Ideally we want a cache for the version of the puppet agent used in tests
      desired_name = "#{component}-puppet_agent-#{@puppet_version}.json"
      # By default look for any caches created during previous runs
      cache_file = File.join(@cachedir, desired_name)

      # If the user provides their own cache
      if !@force_update && File.directory?(@manual_vendored_dir)
                # Check for any '<component>-puppet_agent-<puppet version>.json' files
                dg = Dir.glob(File.join(@manual_vendored_dir, "#{component}-puppet_agent*"))
                # Check if there are multiple versions of the component cache
                if dg.size > 1
                  # If there is the same version supplied as whats being tested against use that
                  if dg.any? { |s| s[desired_name] }
                    cache_file = File.join(@manual_vendored_dir, desired_name)
                  # If there are any with the same major version, use the latest supplied
                  elsif dg.any? { |s| s["#{component}-puppet_agent-#{@puppet_major_version}"] }
                    maj_match = dg.select { |f| /#{component}-puppet_agent-#{@puppet_major_version}.\d+\.\d+\.json/.match(f) }
                    maj_match.each do |f|
                      next unless (version_from_file(cache_file) == version_from_file(desired_name)) || (version_from_file(f) >= version_from_file(cache_file))

                      # if the current cache version matches the desired version, use the first matching major version in user cache
                      # if there are multiple major version matches in user cache, use the latest
                      cache_file = f
                    end
                  # Otherwise just use the latest supplied
                  else
                    dg.each { |f| cache_file = f if version_from_file(f) >= version_from_file(cache_file) }
                  end
                # If there is only one use that
                elsif dg.size == 1
                  cache_file = dg[0]
                end
      end

      # Warn the user if cached version does not match whats being used to test
      cache_version = version_from_file(cache_file)
      logger.warn "Cache for #{component} is for puppet_agent #{cache_version}, while you are testing against puppet_agent #{@puppet_version}. Consider updating your cache to ensure consistent behavior in your tests" if cache_version != @puppet_version

      cache_file
    end

    def version_from_file(cache_file)
      version_regex = /.*-puppet_agent-(\d+\.\d+\.\d+)\.json/
      Gem::Version.new(version_regex.match(cache_file)[1])
    end

    # Currently expects to be passed a R10K::Puppetfile object.
    # ex: R10K::ModuleLoader::Puppetfile.new(basedir: '.')
    def puppetfile_missing_vendored(puppetfile)
      puppetfile.load
      @vendored_references.each do |mod|
        # Extract name and slug from url
        mod_slug = mod['url'].match(/.*(puppetlabs-\w+)\.git/)[1]
        mod_name = mod_slug.match(/^puppetlabs-(\w+)$/)[1]
        # Array of modules whos names match
        existing = puppetfile.modules.select { |e_mod| e_mod.name == mod_name }
        if existing.empty?
          # Change url to https instead of ssh to allow anonymous git clones
          # so that users do not need to have an ssh keypair associated with a Github account
          url = mod['url'].gsub('git@github.com:', 'https://github.com/')
          @missing_vendored << { mod_slug => { git: url, ref: mod['ref'] } }
          logger.debug "#{mod_name} found to be missing in Puppetfile"
        else
          logger.debug "#{mod_name} found in Puppetfile. Using the specified version"
        end
      end
    end

    # Return json from a query whom caches, or from the cache to avoid spamming github
    def query_or_cache(url, params, filepath)
      if (File.exist? filepath) && (@force_update == false)
        logger.debug "Using cache: #{filepath}"
        json = read_json_dump(filepath)
      else
        logger.debug "Making GET request to: #{url}"
        json = github_get(url, params)
        logger.debug "Caching response to: #{filepath}"
        write_json_dump(filepath, json)
      end
      json
    end

    # Given a github url and optional query parameters, return the parsed json body
    def github_get(url, params)
      uri = URI.parse(url)
      uri.query = URI.encode_www_form(params) if params
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      request = Net::HTTP::Get.new(uri.request_uri)
      request['Accept'] = 'application/vnd.github.raw+json'
      request['X-GitHub-Api-Version'] = '2022-11-28'
      response = http.request(request)

      case response
      when Net::HTTPOK # 200
        MultiJson.load(response.body)
      else
        # Expose the ratelimit response headers
        # https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api?apiVersion=2022-11-28#checking-the-status-of-your-rate-limit
        ratelimit_headers = response.to_hash.select { |k, _v| k =~ /x-ratelimit.*/ }
        raise "#{response.code} #{response.message} #{ratelimit_headers}"
      end
    end

    # Returns parsed json of file
    def read_json_dump(filepath)
      MultiJson.load(File.read(filepath))
    end

    # Writes json to a file
    def write_json_dump(filepath, json_data)
      File.write(filepath, MultiJson.dump(json_data))
    end
  end
end
