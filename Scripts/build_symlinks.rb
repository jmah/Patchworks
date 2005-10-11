#!/usr/bin/env ruby
#
# build_symlinks.rb
# Patchworks
#
# Created by Jonathon Mah on 2005-10-08.
# Copyright 2005 Playhaus. All rights reserved.
# This file is in the public domain. Feel free to copy and use it in any way.
# This file is specifically excluded from the conditions in 'LICENSE.txt'.


Links = [
  # Format:
  # [ link path , link target ],
  # Link path is relative to project root
  
  # OgreKit
  [ 'Frameworks/OgreKit.framework/Headers', 'Versions/Current/Headers'],
  [ 'Frameworks/OgreKit.framework/OgreKit', 'Versions/Current/OgreKit'],
  [ 'Frameworks/OgreKit.framework/Resources', 'Versions/Current/Resources'],
  [ 'Frameworks/OgreKit.framework/Versions/Current' , 'A'],
  
]



# Build links
require 'FileUtils'

Links.each do |path,target|
  puts "Creating symlink #{path} -> #{target}"
  FileUtils.rm path, :force => true
  FileUtils.ln_s target, path, :force => true
end
