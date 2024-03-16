RSpec::Matchers.define :satisfy_file_resource_requirements do
  match do |catalog|
    @missing_param = catalogue.resources.map do |resource|
      next if !(resource.type == 'File')
        if resource[:mode]
          if resource[:mode] =~ /777|\d.*7$/
            "Found use of unsafe file mode for file #{resource}, mode: #{resource[:mode]}"
          end
        end
      end.compact
      @missing_param.empty?
    end
  failure_message do |str|
    @missing_param.join("\n")
  end
end
