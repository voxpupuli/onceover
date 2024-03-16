# == Class: profile::base::windows::hardening
#
class profile::base::windows::hardening (
  Boolean $enable_noop = false,
) {
  noop($enable_noop)

  # CIS Benchmark section 18.3.1
  registry_value { 'AutoAdminLogon':
    path => 'HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon',
    data => '0',
  }

  # CIS Benchmark section 18.3.9
  registry_value { 'ScreenSaverGracePeriod':
    path => 'HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\ScreenSaverGracePeriod',
    data => '5',
  }

  # CIS Benchmark section 18.3.8
  registry_value { 'SafeDllSearchMode':
    path => 'HKLM\System\CurrentControlSet\Control\Session Manager\SafeDllSearchMode',
    data => '1',
  }

  # CIS Benchmark section 18.3.12
  registry_value { 'WarningLevel':
    path => 'HKLM\System\CurrentControlSet\Services\Eventlog\Security\WarningLevel',
    data => '90',
  }

  # Set detailed permissions on the app directory
  acl { 'C:\app':
    group                      => 'Administrators',
    inherit_parent_permissions => false,
    purge                      => true,
    owner                      => 'Administrator',
    permissions                => [
      {
        'affects'  => 'self_only',
        'identity' => 'NT AUTHORITY\SYSTEM',
        'rights'   => ['full']
      },
      {
        'affects'  => 'self_only',
        'identity' => 'BUILTIN\Administrators',
        'rights'   => ['full']
      },
      {
        'affects'  => 'self_only',
        'identity' => 'BUILTIN\Users',
        'rights'   => ['read', 'execute']
      }
    ],
    require                    => File['C:\app'],
  }
}
