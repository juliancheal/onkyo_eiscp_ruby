module EISCP
  module Dictionary
    module DictionaryHelpers

      # Return the zone that includes the given command
      def zone_from_command(command)
        @zones.each do |zone|
          @commands[zone].each_pair do |k, v|
            if command == k
              return zone
            end
          end
        end
        return nil
      end

      # Return the human readable name of a command
      def command_to_name(command)
        command = command.upcase
        begin
          zone = zone_from_command(command)
          return @commands[zone][command]['name']
        rescue
          return nil
        end
      end

      # Return the command from a given command name
      def command_name_to_command(name, zone = nil)
        if zone.nil?

          @zones.each do |zone|
            @commands[zone].each_pair do |command, attrs|
              if attrs['name'] == name
                return command
              end
            end
            return nil
          end

        else

          @commands[zone].each_pair do |command, attrs|
            if attrs['name'] == name
              return command
            end
          end
          return nil

        end

      end

      # Return a command value name from a command and value
      def command_value_to_value_name(command, value)
        begin
          zone = zone_from_command(command)
          return @commands[zone][command]['values'][value]['name']
        rescue
          return nil
        end
      end

      # Return a command value from a command and value name
      def command_value_name_to_value(command, value_name)
        zone = zone_from_command(command)
        @commands[zone][command]['values'].each_pair do |k, v|
          if v['name'] == value_name.to_s
            return k
          end
        end
        return nil
      end

      # Return a description form a command name and zone
      def description_from_command_name(name, zone)
        @commands[zone].each_pair do |command, attrs|
          if attrs['name'] == name
            return @commands[zone][command]['description']
          end
        end
        return nil
      end

      # Return a description from a command
      def description_from_command(command)
        begin
          zone = zone_from_command(command)
          return @commands[zone][command]['description']
        rescue
          return nil
        end
      end

      # Return a description from a command and value
      def description_from_command_value(command, value)
        zone = zone_from_command(command)
        return @commands[zone][command]['values'].select do |k, v|
          if k == value
            return v['description']
          end
        end
        return nil
      end

      # Return a list of commands compatible with a given model
      def list_compatible_commands(modelstring)
        sets = []
        @modelsets.each_pair do |set, array|
          if array.include? modelstring
            sets << set
          end
        end
        return sets
      end

      def validate_command(command)
        begin
          zone = zone_from_command(command)
          @commands[zone].include? command
        rescue
          false
        end
      end

      # Parse a command and return a message object
      #def parse(string)
      #  array = string.split(" ")
      #  zone = DEFAULT_ZONE
      #  command_name = ''
      #  value_name = ''
      #  if array.count == 3
      #    zone = array.shift
      #    command_name = array.shift
      #    value_name = array.shift
      #  elsif array.count == 2
      #    command_name = array.shift
      #    value_name = array.shift
      #  end
      #  begin
      #    command = command_name_to_command(command_name, zone)
      #    value = command_value_name_to_value(command, value_name)
      #    return EISCP::Message.new(command, value)
      #  rescue
      #    return nil
      #  end
      #end
    end
  end
end