class Controlrepo_beaker
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
        version = facts['os']['distro']['release']['major']
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

    "puppetlabs/#{os}-#{version}-#{arch}-nocm"
  end
end