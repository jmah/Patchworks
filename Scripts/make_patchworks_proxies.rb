#!/usr/bin/env ruby
#
# make_patchworks_proxies.rb
# Patchworks
#
# Created by Jonathon Mah on 2005-10-11.
# Copyright 2005 Playhaus. All rights reserved.
# License information is contained at the bottom of this file and in the
# 'LICENSE.txt' file.

require 'FileUtils'


gz_patches = Dir::glob '_darcs/patches/*.gz'

if gz_patches.empty?
  $stderr.puts 'No patches found. Are you in the repository root?'
  exit 1
end

ProxyDirPath = '_darcs/third_party/patchworks'
ProxyExtension = 'darcsPatchProxy'
FileUtils::mkdir_p ProxyDirPath unless File.directory? ProxyDirPath

patch_basenames = gz_patches.collect {|gz| File::basename gz, '.gz' }
proxy_basenames = Dir::glob("#{ProxyDirPath}/*.#{ProxyExtension}").collect {|proxy| File::basename proxy, ".#{ProxyExtension}" }

proxies_to_add = patch_basenames - proxy_basenames
proxies_to_remove = proxy_basenames - patch_basenames

# Add proxies for new patches
proxies_to_add.each do |proxy|
  puts "Adding proxy for #{proxy}"
  File::open "#{ProxyDirPath}/#{proxy}.#{ProxyExtension}", 'w' do |f|
    f.puts 'This is a placeholder for a darcs patch file.'
  end
end

# Remove proxies for non-existent patches
proxies_to_remove.each do |proxy|
  puts "Removing proxy for #{proxy}"
  File::delete "#{ProxyDirPath}/#{proxy}.#{ProxyExtension}"
end


# Patchworks is licensed under the BSD license, as follows:
# 
# Copyright (c) 2005, Playhaus
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the Playhaus nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
# 
# This software is provided by the copyright holders and contributors "as is"
# and any express or implied warranties, including, but not limited to, the
# implied warranties of merchantability and fitness for a particular purpose
# are disclaimed. In no event shall the copyright owner or contributors be
# liable for any direct, indirect, incidental, special, exemplary, or
# consequential damages (including, but not limited to, procurement of
# substitute goods or services; loss of use, data, or profits; or business
# interruption) however caused and on any theory of liability, whether in
# contract, strict liability, or tort (including negligence or otherwise)
# arising in any way out of the use of this software, even if advised of the
# possibility of such damage.
