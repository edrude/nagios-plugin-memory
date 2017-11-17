#!/usr/bin/env ruby

require 'optparse'

OK_STATE = 0
WARNING_STATE = 1
CRITICAL_STATE = 2
UNKNOWN_STATE = 3

PROC_MEMINFO_PATH = "/proc/meminfo"

AVAILABLE_MEMORY_ATTR = "MemAvailable"
TOTAL_MEMORY_ATTR = "MemTotal"

WARNING_DEFAULT = 20
CRITICAL_DEFAULT = 10

#Determine if value is integer
def self.integer?(val)
  Integer(val) != nil rescue false
end

#Use the constants at the top of the script to extract select values from /proc/meminfo
def self.get_mem_stats

  memory_stats = {}

  File.open(PROC_MEMINFO_PATH, "r") do |file_handle|
    file_handle.each_line do |file_line|
      case file_line
      when /^#{AVAILABLE_MEMORY_ATTR}: +(\d+) kB$/
        memory_stats[:available] = Regexp.last_match(1).to_f
      when /^#{TOTAL_MEMORY_ATTR}: +(\d+) kB$/
        memory_stats[:total] = Regexp.last_match(1).to_f
      end
    end
  end
  memory_stats
end

def self.get_options
  supplied_options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{File.basename $0} [options]"

    opts.on("-w", "--warning WARNING", "Integer percentage available to alert warning") do |w|
      if !integer?(w)
        raise OptionParser::InvalidArgument, "must be an integer between 0 and 100"
      elsif !w.to_i.between?(0,100)
        raise OptionParser::InvalidArgument, "must be an integer between 0 and 100"
      end
      supplied_options[:warn] = w
    end

    opts.on("-c", "--critical CRITICAL", "Whole number percentage available to alert critical") do |c|
      if !integer?(c)
        raise OptionParser::InvalidArgument, "must be an integer between 0 and 100"
      elsif !c.to_i.between?(0,100)
        raise OptionParser::InvalidArgument, "must be an integer between 0 and 100"
      end
      supplied_options[:crit] = c
    end
  end.parse!

  #Merge default values with supplied values
  options = {}
  options[:warn] = supplied_options.fetch(:warn, WARNING_DEFAULT).to_i
  options[:crit] = supplied_options.fetch(:crit, CRITICAL_DEFAULT).to_i

  if options[:warn] < options[:crit]
    raise OptionParser::InvalidArgument, "WARNING must be greater than or equal to CRITICAL"
  end

  options
end

begin
  options = get_options

  memory_stats = get_mem_stats
  memory_stats[:percent_available] = (10000 * (memory_stats[:available] / memory_stats[:total])).round * 0.01

  if memory_stats[:percent_available].between?(0, options[:crit])
    puts "CRITICAL: #{memory_stats[:percent_available]}% (#{(memory_stats[:available] / 1024).round}MB) of memory available"
    exit(CRITICAL_STATE)
  elsif memory_stats[:percent_available].between?(options[:crit], options[:warn])
    puts "WARNING: #{memory_stats[:percent_available]}% (#{(memory_stats[:available] / 1024).round}MB) of memory available"
    exit(WARNING_STATE)
  elsif memory_stats[:percent_available].between?(options[:warn], 100)
    puts "OK: #{memory_stats[:percent_available]}% (#{(memory_stats[:available] / 1024).round}MB) of memory available"
    exit(OK_STATE)
  else
    puts "UNKNOWN: unable to determine available % range"
    exit(UNKNOWN_STATE)
  end

rescue
  puts "UNKNOWN: exception during #{File.basename $0} execution"
  exit(UNKNOWN_STATE)
end
