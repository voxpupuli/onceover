& 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat' apply -e "include $($env:PT_role)" | Out-Null

$report = (& 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat' config print lastrunreport)

& 'C:\Program Files\Puppet Labs\Puppet\bin\ruby.exe' -rjson -ryaml -rpuppet -e "puts YAML.load_file('$($report)').to_json"
