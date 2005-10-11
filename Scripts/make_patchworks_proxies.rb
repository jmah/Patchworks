#!/usr/bin/env ruby

gz_patches = Dir::glob '_darcs/patches/*.gz'

if gz_patches.empty?
  $stderr.puts 'No patches found. Are you in the repository root?'
  exit 1
end

ProxyDirPath = '_darcs/patchworks'
ProxyExtension = 'darcsPatchProxy'
Dir::mkdir ProxyDirPath unless File.directory? ProxyDirPath

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
