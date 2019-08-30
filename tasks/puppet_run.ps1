$output = (& 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat' apply -e "include $($env:PT_role)" | Out-String)

$report = (& 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat' config print lastrunreport)

if (Test-Path $report) {
  & 'C:\Program Files\Puppet Labs\Puppet\bin\ruby.exe' -rjson -ryaml -rpuppet -e "puts YAML.load_file('$($report)').to_json"
} else {
  Write-Host $output
  exit 1
} 
