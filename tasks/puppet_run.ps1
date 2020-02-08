try {
  # Get the settings we are going to need to work out where files are
  $manifest        = (& 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat' config print manifest | Out-String).Trim()
  $environmentpath = (& 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat' config print environmentpath | Out-String).Trim()

  # Create a temp file to apply
  $apply_manifest      = [System.IO.Path]::GetTempFileName()
  $log                 = "$([System.IO.Path]::GetTempFileName()).json"
  $pre_conditions_path = "$($environmentpath)/production/spec/pre_conditions"

  # Include the manifest and all pre_conditions
  Get-ChildItem "$($manifest)/*.pp"            | Get-Content | Add-Content $apply_manifest
  Get-ChildItem "$($pre_conditions_path)/*.pp" | Get-Content | Add-Content $apply_manifest
  "include $($env:PT_role)"                                  | Add-Content $apply_manifest

  # Run puppet
  & 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat' apply $apply_manifest --logdest $log 2>&1 | out-null

  $report = (& 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat' config print lastrunreport)

  # Close off the logs
  "]" | Add-Content $log

  # Parse and print logs and report
  #
  # This simply doesn't work
  & 'C:\Program Files\Puppet Labs\Puppet\puppet\bin\ruby.exe' "$($env:PT_installdir)/onceover/somegarbage/files/run_details.rb" $log $report

  # Debugging
  "apply_manifest: $($apply_manifest)" | Add-Content C:\bolt.log
  "log: $($log)" | Add-Content C:\bolt.log
  "report: $($report)" | Add-Content C:\bolt.log
  "pre_conditions_path: $($pre_conditions_path)" | Add-Content C:\bolt.log
  "manifest: $($manifest)" | Add-Content C:\bolt.log
  "environmentpath: $($environmentpath)" | Add-Content C:\bolt.log
  "LOGS:" | Add-Content C:\bolt.log
  Get-Content $log | Add-Content C:\bolt.log

} catch {
  Write-Error "An error occurred:"
  Write-Error $_
  exit 1
}