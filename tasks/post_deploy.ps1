try {
  # Get the location of environment.conf
  $envpath          = (& 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat' config print environmentpath | Out-String).Trim()
  $environment_conf = "$($envpath)/production/environment.conf"

  if (Test-Path $environment_conf) {
    # Replace colons with semicolons as they are the correct path separator
    $content = ((Get-Content -Path $environment_conf -Raw).Replace("`n","`r`n") -replace ':',';')

    # Remove config_version as it probably won't work on Windows
    $content.Replace("config_version","#config_version") | Set-Content $environment_conf

  }
} catch {
  Write-Error "An error occurred:"
  Write-Error $_
  exit 1
}