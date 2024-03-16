#! /bin/env ruby

files = `git --no-pager diff --name-only HEAD HEAD~1`.split("\n")
classes = []

files.each do |file|
  # if the changed file is a manifest
  if file =~ /\.pp$/
    segments = file.split('/')
    # Capitalize the segments so that they work as a reference
    segments = segments.map { |seg| seg.capitalize }
    # Get the name of the module
    mod = segments[segments.index('Manifests') - 1]
    # Delete everything up to & including manifests
    segments = segments - segments[0..segments.index('Manifests')]
    # Get the final section
    final = segments.last.chomp('.pp')
    # Delete it
    segments.delete(segments.last)
    # Get anything taht is left
    intermediary = segments
    classes << [mod,intermediary,final].flatten.join('::')
  end
end

puts classes.length
