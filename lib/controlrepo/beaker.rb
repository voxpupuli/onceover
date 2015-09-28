class Controlrepo::Beaker
  def self.facts_to_vagrant_box(facts)
    # Gets the most similar vagrant box to the facts set provided
    if facts['os']['distro']['id'] == 'Ubuntu'
      os = 'ubuntu'
      version = facts['os']['distro']['release']['major']
    elsif facts['os']['distro']['id'] == 'Debian'
      os = 'Debian'
      version = facts['os']['distro']['release']['major']
    elsif facts['os']['family'] == "RedHat"
      os = 'centos'
      version = "#{facts['os']['release']['major']}.#{facts['os']['release']['minor']}"
    end

    if facts['os']['architecture'] =~ /64/
      arch = '64'
    else
      arch = '32'
    end

    "puppetlabs/#{os}-#{version}-#{arch}-nocm"
  end
end