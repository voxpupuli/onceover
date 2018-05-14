Given(/^in Puppetfile is misspelled module's name$/) do
  @repo.add_line_to_puppetfile %Q(mod "acme/not_exists", "7.7.7")
end

Then(/^I should see generated all necessary files and folders$/) do
  files = [ 'spec/onceover.yaml', 'Rakefile', 'Gemfile' ].map { |x| @repo.root_folder + x }
  folders = [ 'spec/factsets', 'spec/pre_conditions'].map! { |x| @repo.root_folder + x}

  files.each do |file|
    puts file
    expect( File.exist? file ).to be true
  end
  folders.each do |folder|
    puts folder
    expect( Dir.exist? folder ).to be true
  end
end
