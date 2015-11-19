class Controlrepo
  class Beaker
    def self.facts_to_vagrant_box(facts)
      # Gets the most similar vagrant box to the facts set provided, will accept a single fact
      # se or an array

      if facts.is_a?(Array)
        returnval = []
        facts.each do |fact|
          returnval << self.facts_to_vagrant_box(fact)
        end
        return returnval
      end

      begin
        if facts['os']['distro']['id'] == 'Ubuntu'
          os = 'ubuntu'
          version = facts['os']['distro']['release']['major']
        end
      rescue
        # Do nothing, this is the easiest way to handle the hash bing in different formats
      end

      begin
        if facts['os']['distro']['id'] == 'Debian'
          os = 'Debian'
          version = "#{facts['os']['distro']['release']['major']}.#{facts['os']['distro']['release']['minor']}"
        end
      rescue
        # Do nothing
      end

      begin
        if facts['os']['family'] == "RedHat"
          os = 'centos'
          version = "#{facts['os']['release']['major']}.#{facts['os']['release']['minor']}"
        end
      rescue
        # Do nothing
      end

      return "UNKNOWN" unless os.is_a?(String)

      if facts['os']['architecture'] =~ /64/
        arch = '64'
      else
        arch = '32'
      end

      "puppetlabs/#{os}-#{version}-#{arch}-puppet"
    end

    # This will take a fact set and return the beaker platform of that machine
    # This is necissary as beaker needs the platform set up correctly to know which
    # commands to run when we do stuff. Personally I would prefer beaker to detect the
    # platform as it would not be that hard, especially once puppet is installed, oh well.
    def self.facts_to_platform(facts)
      if facts.is_a?(Array)
        returnval = []
        facts.each do |fact|
          returnval << self.facts_to_platform(fact)
        end
        return returnval
      end

      begin
        if facts['os']['family'] == 'RedHat'
          platform = 'el'
          version = facts['os']['release']['major']
        end
      rescue
        # Do nothing, this is the easiest way to handle the hash bing in different formats
      end

      begin
        if facts['os']['distro']['id'] == 'Ubuntu'
          platform = 'ubuntu'
          version = facts['os']['distro']['release']['major']
        end
      rescue
        # Do nothing, this is the easiest way to handle the hash bing in different formats
      end

      begin
        if facts['os']['distro']['id'] == 'Debian'
          platform = 'Debian'
          version = facts['os']['distro']['release']['major']
        end
      rescue
        # Do nothing
      end

      if facts['os']['architecture'] =~ /64/
        arch = '64'
      else
        arch = '32'
      end

      "#{platform}-#{version}-#{arch}"
    end

    # This little method will deploy a Controlrepo object to a host, just using r10k deploy
    def self.deploy_controlrepo_on(host, repo = Controlrepo.new())
      require 'beaker-rspec'
      require 'controlrepo'

      if host.is_a?(Array)
        hosts.each do |single_host|
          deploy_controlrepo_on(single_host)
        end
      end

      # Use a beaker helper to do the install (*nix only)
      install_r10k_on(host)

      # Use beaker to install git
      host.install_package('git')

      # copy the file over to the host (Maybe I should be changing the directory here??)
      scp_to(host,repo.r10k_config_file,'/tmp/r10k.yaml')

      # Do an r10k deploy
      r10k_deploy(host,{
        :puppetfile => true,
        :configfile => '/tmp/r10k.yaml',
        })
    end

    # This actually provisions a node and checks that puppet will be able to run and
    # be idempotent. It hacks the beaker NetworkManager object to do this. The reason
    # is that beaker is designed to run in the following order:
    #   1. Spin up nodes
    #   2. Run all tests
    #   3. Kill all nodes
    #
    # This is not helpful for us. We want to be able to test all of our classes on
    # all of our nodes, this could be a lot of vms and having them all running at once
    # would be a real kick in the dick for whatever system was running it.
    def self.provision_and_test(host,puppet_class,opts = {},repo = Controlrepo.new)
      opts = {:runs_before_idempotency => 1}.merge(opts)
      opts = {:check_idempotency => true}.merge(opts)
      opts = {:deploy_controlrepo => true}.merge(opts)


      raise "Hosts must be a single host object, not an array" if host.is_a?(Array)
      raise "Class must be a single Class [String], not an array" unless puppet_class.is_a?(String)

      # Create our own NWM object that we are going to interact with
      # Note here that 'options', 'logger' and are exposed within the rspec tests
      # if this is run outside of that context it will fail
      network_manager = ::Beaker::NetworkManager.new(options,logger)

      # Hack the network manager to smash our host in there without provisioning
      network_manager.instance_variable_set(:@hosts,[host])

      # Now that we have a working network manager object, we can provision, but only if
      # we need to, ahhh smart...
      unless host.up?
        network_manager.provision
        network_manager.proxy_package_manager
        network_manager.validate
        network_manager.configure
      end

      # Actually run the tests
      manifest = "include #{puppet_class}"

      opts[:runs_before_idempotency].times do
        apply_manifest_on(host,manifest,{:catch_failures => true})
      end

      if opts[:check_idempotency]
        apply_manifest_on(host,manifest,{:catch_changes => true})
      end

      network_manager.cleanup
    end

  end
end