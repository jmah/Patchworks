#!/usr/bin/ruby


class XcodeBuildMessage
  attr_reader :type
  attr_accessor :file, :line_number, :message
  
  ErrorStrings = { :error => 'error', :warning => 'warning' }
  
  def initialize(type)
    raise "'#{type.to_s} is not a valid message type" unless ErrorStrings.has_key? type
    
    @type = type
    @message = String.new
    @file = String.new
    @line_number = 1
  end
  
  def to_s
    "#{@file}:#{@line_number.to_s}: #{ErrorStrings[@type]}: #{@message}"
  end
end


base_dir = ENV['SRCROOT'] || '.'

# Build find command
find_cmd = "find '#{base_dir}' -name '*.plist'"
# Exclude certain directories
['_darcs', '.svn', 'CVS', 'build'].each do |dir|
  find_cmd << " -and -not -path '*/#{dir}/*'"
end

plist_files = `#{find_cmd}`.split $/


error_count = 0
plist_files.each do |plist|
  output = `plutil -lint -s '#{plist}'`

  errors = []
  unless output.chomp.empty?
    lines = output.split $/
    lines.shift # Throw away file path (we already have it)
    
    until lines.empty?
      xcode_error = XcodeBuildMessage.new :error
      xcode_error.file = plist
      xcode_error.message = lines.shift
      
      until lines.empty?
        next_line = lines.shift
        md = next_line.match(/^\s+(\S.+) (at|on) line (\d+)(.*)$/)
        if md
          xcode_error.line_number = md[3].to_i
          xcode_error.message << ' ' << md[1] << ' ' << md[4]
        else
          lines.unshift next_line
          break
        end
      end
      
      errors << xcode_error
    end
  end
  
  errors.sort_by {|err| err.line_number }.each {|err| puts err.to_s }
  
  if errors.empty?
    puts "Test #{File::basename plist} passed (plist OK)"
  else
    puts "Test #{File::basename plist} failed"
    error_count += 1
  end
end

if error_count == 0
  puts "Passed #{plist_files.size} property lists"
  exit 0
else
  puts "Failed #{error_count} out of #{plist_files.size} property lists"
  exit 1
end
