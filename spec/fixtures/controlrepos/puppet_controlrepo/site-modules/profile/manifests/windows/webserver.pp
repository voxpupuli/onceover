#
class profile::windows::webserver {
  # Install the IIS role
  dsc_windowsfeature { 'IIS':
    dsc_ensure => 'present',
    dsc_name   => 'Web-Server',
  }

  dsc_windowsfeature { 'IIS Console':
    dsc_ensure => 'present',
    dsc_name   => 'Web-Mgmt-Console',
  }

  # Install the ASP .NET 4.5 role
  dsc_windowsfeature { 'AspNet45':
    dsc_ensure => 'present',
    dsc_name   => 'Web-Asp-Net45',
  }

  # Stop an existing website (set up in Sample_xWebsite_Default)
  dsc_xwebsite { 'Stop DefaultSite':
    dsc_ensure => 'present',
    dsc_name   => 'Default Web Site',
    dsc_state  => 'Stopped',
    require    => Dsc_windowsfeature['IIS','AspNet45'],
  }
}
