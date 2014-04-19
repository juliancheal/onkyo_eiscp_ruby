require 'yaml'
require_relative './receiver'
require 'ostruct'

module EISCP
  module Command

    @@yaml_file_path = File.join(File.expand_path(File.dirname(__FILE__)), '../../eiscp-commands.yaml')
    @@yaml_object = YAML.load(File.read(@@yaml_file_path))
    @@modelsets = @@yaml_object["modelsets"]
    @@yaml_object.delete("modelsets")
    @@zones = @@yaml_object.map{|k, v| k}
    @@zones.each {|zone| class_variable_set("@@#{zone}", nil) }
    @@main = @@yaml_object['main']
    @@zone_modules = {}

    def zone_module(name, options={}, &block)
      @@zone_modules[name] = Class.new(options[:base] || EISCP::Zone, &block)
    end






    def self.command_to_name(command)
      return @@main[command]['name']
    end

    def self.command_name_to_command(name)
      @@main.each_pair do |command, attrs|
        if attrs['name'] == name
          return command
        end
      end
    end

    def self.command_value_to_value_name(command, value)
      return @@main[command]['values'][value]['name'] 
    end

    def self.command_value_name_to_value(command, name)
      @@main[command]['values'].each do |k, v|
        if v['name'] == name.to_s
          return k
        end
      end
    end


    def self.description_from_command_name(name)
      @@main.each_pair do |command, attrs|
        if attrs['name'] == name
          return @@main[command]['description']
        end
      end
    end

    def self.description_from_command(command)
      return @@main[command]['description']
    end

    def self.description_from_command_value(command, value)
      return @@main[command]['values'].select do |k, v| 
        if k == value
          return v['description']
        end
      end
    end

    def self.list_all_commands
      @@main.each_pair do |command, attrs|
        puts "#{command} - #{attrs['name']}: #{attrs['description']}"
        attrs['values'].each_pair do |k, v|
          puts "--#{k}:#{v}"
        end
      end
    end

    def self.list_compatible_commands(modelstring)
      sets = [] 
      @@modelsets.each_pair do |set, array|
        if array.include? modelstring
          sets << set
        end
      end
      return sets
    end

    def self.parse(string)
      array = string.split(" ")
      zone = 'main'
      command_name = ''
      parameter_name = ''
      if array.count == 3
        zone = array.shift
        command_name = array.shift
        parameter_name = array.shift
      elsif array.count == 2
        command_name = array.shift
        parameter_name = array.shift
      end
      command = command_name_to_command(command_name)
      parameter = command_value_name_to_value(command, parameter_name)
      return EISCP::Message.new(command, parameter)
    end
  end
end
