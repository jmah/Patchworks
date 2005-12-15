#!/usr/bin/env ruby
#
# run_unit_tests.rb
# Patchworks
#
# Created by Jonathon Mah on 2005-10-08.
# Copyright 2005 Playhaus. All rights reserved.
# This file is in the public domain. Feel free to copy and use it in any way.
# This file is specifically excluded from the conditions in 'LICENSE.txt'.


# This file is indented to be run from the project root
if $0 == __FILE__
  $:.unshift 'Scripts'
  require 'XcodeBuildCommand'
  
  # First, make the required symlinks in case they don't already exist
  require 'build_symlinks.rb'
  puts
  
  test_proj = XcodeBuildCommand.new 'Patchworks.xcodeproj'
  test_proj.target = 'Unit Tests'
  test_proj.configuration = 'Unit Tests'
  
  success = test_proj.run do |line|
    case line
    when /^=== /
      print line
    when /^PhaseScriptExecution /
      puts 'Executing test script...'
    when /^\d{4}-\d{2}-\d{2}/
      # Assume this is console output (e.g. from NSLog)
      print line
    when /^Test /
      # Assume this is test output
      print line
    when /^(Passed |Failed )/
      # Assume this is the end of each test output
      print line
      puts
    end
  end

  exit success
end
