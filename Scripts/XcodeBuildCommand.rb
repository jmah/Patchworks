#!/usr/bin/env ruby
#
# XcodeBuildCommand.rb
# Patchworks
#
# Created by Jonathon Mah on 2005-10-08.
# Copyright 2005 Playhaus. All rights reserved.
# This file is in the public domain. Feel free to copy and use it in any way.
# This file is specifically excluded from the conditions in 'LICENSE.txt'.


require 'english'


# This class is a wrapper around the 'xcodebuild' command. This is not meant
# to be a comprehensive wrapper, merely the least necessary to perform
# testing.  But I tend to go over the top. :)  -- Jonathon Mah

class XcodeBuildCommand
  # Build command properties
  attr_reader :project_path, :target, :configuration, :build_actions, :other_settings
  
  def initialize(project_path = '')
    raise "'#{new_path}' is not a valid path to an Xcode project" unless (File.directory? project_path.to_s and project_path.to_s =~ /.*\.xcode(proj)?/) or project_path.to_s == ''
    @project_path = project_path.to_s
    
    # Find the valid targets and configurations in a new thread, because it's really slow
    @init_thread = Thread.new do
      @valid_targets = []
      @valid_configurations = []
      read_state = nil # Valid values are [:targets, :configurations, :end]
      if @project_path.empty?
        list_cmd = "xcodebuild -list"
      else
        list_cmd = "xcodebuild -project '#@project_path' -list"
      end
      
      list_output = `#{list_cmd}`
      list_output.each do |line|
        if line =~ /^ {4}[^ ]/
          # We have a marker of upcoming tokens
          case line.strip
          when 'Targets:'
            read_state = :targets
          when 'Build Configurations:'
            read_state = :configurations
          when /^If no build configuration is specified ".*" is used\.$/
            read_state = :end
          end
        elsif line =~ /^ {8}[^ ]/
          # We have an interesting token (a target or configuration)
          case read_state
          when :targets
            @valid_targets << line.strip.chomp(' (Active)')
            @active_target = @valid_targets[-1] if line.strip =~ / \(Active\)$/
          when :configurations
            @valid_configurations << line.strip.chomp(' (Active)')
            @active_configuration = @valid_configurations[-1] if line.strip =~ / \(Active\)$/
          end
        end
        
        break if read_state == :end
      end
    end # init_thread
    
    @valid_build_actions = [ :build, :installsrc, :install, :clean ]
    
    # Set default values
    @target = :active
    @configuration = :active
    @build_actions = [:build]
    @other_settings = Hash.new
  end
  
  
  # Project properties
  
  attr_reader :valid_build_actions
  
  def active_target
    if @init_thread
      @init_thread.join
      @init_thread = nil
    end
    @active_target
  end
  
  def active_configuration
    if @init_thread
      @init_thread.join
      @init_thread = nil
    end
    @active_configuration
  end
  
  def valid_targets
    if @init_thread
      @init_thread.join
      @init_thread = nil
    end
    @valid_targets
  end
  
  def valid_configurations
    if @init_thread
      @init_thread.join
      @init_thread = nil
    end
    @valid_configurations
  end
  
  
  def target=(new_target)
    valid_target = nil
    catch :valid do
      if new_target == :all or new_target == :active
        valid_target = new_target
        throw :valid
      end
      
      target_str = nil
      begin
        target_str = new_target.to_s
      end
      if target_str != nil
        if valid_targets.include? target_str
          valid_target = target_str
          throw :valid
        else
          raise "#{target_str} is not a valid target"
        end
      end
    end
    
    if valid_target
      @target = valid_target
    else
      raise <<QUOTE
Valid values for 'target':
  :all      Build all targets
  :active   Build the active target
  String    Build the named target
QUOTE
    end
  end
  
  def configuration=(new_configuration)
    valid_configuration = nil
    catch :valid do
      if new_configuration == :active
        valid_configuration = new_configuration
        throw :valid
      end
      
      configuration_str = nil
      begin
        configuration_str = new_configuration.to_s
      end
      if configuration_str != nil
        if valid_configurations.include? configuration_str
          valid_configuration = configuration_str
          throw :valid
        else
          raise "#{configuration_str} is not a valid configuration"
        end
      end
    end
    
    if valid_configuration
      @configuration = valid_configuration
    else
      raise <<QUOTE
Valid values for 'configuration':
  :active   Use the active configuration
  String    Use the named configuration
QUOTE
    end
  end
  
  def build_actions=(new_actions)
    valid_actions = nil
    catch :valid do
      action_sym = nil
      begin
        action_sym = new_actions.to_sym
      end
      if action_sym != nil
        if valid_build_actions.include? action_sym
          valid_actions = [action_sym]
          throw :valid
        else
          raise "#{action_sym.to_s} is not a valid build action"
        end
      end
      
      action_ary = nil
      begin
        action_ary = new_actions.to_a.collect {|a| a.to_sym }
        action_ary = nil if action_ary.size == 0
      end
      if action_ary != nil
        if action_ary.all? {|a| valid_build_actions.include? a }
          valid_actions = action_ary
          throw :valid
        else
          raise "[#{action_ary.join ', '}] contains invalid build actions"
        end
      end
    end
    
    if valid_actions
      @build_actions = valid_actions
    else
      raise <<QUOTE
Valid values for 'build_actions':
  :build    Build the target in the build root (SYMROOT)
  :installsrc Copy the source of the project to the source root (SRCROOT)
  :install  Build the target and install it into the target's installation
            directory in the distribution root (DSTROOT)
  :clean    Remove build products and intermediate files from the build root
            (SYMROOT)
  String    A string version of any of the above
  Array     An array of any of the above (order will be retained)
QUOTE
    end
  end
  
  def other_settings=(new_settings)
    @other_settings = new_settings.to_hash
  end
  
  def command_args
    args = []
    
    # Project path
    if project_path != ''
      args << "-project '#{project_path}'"
    end
    
    # Target
    case target
    when :all
      args << '-alltargets'
    when :active
      args << '-activetarget'
    else
      args << "-target '#{target}'"
    end
    
    # Configuration
    case configuration
    when :active
      args << '-activeconfiguration'
    else
      args << "-configuration '#{configuration}'"
    end
    
    # Build actions
    args.concat build_actions.collect {|a| a.to_s }
    
    # Other settings
    other_settings.each do |setting,value|
      args << "#{setting}=\"#{value}\""
    end
    
    args
  end
  
  def command_string
    "xcodebuild " + command_args.join(' ')
  end
  
  def run
    xcb = IO.popen "#{command_string} 2>&1"
    
    if block_given?
      while line = xcb.gets
        yield line
      end
      
      xcb.close
      $CHILD_STATUS.success?
    else
      xcb.read
    end
  end
end
