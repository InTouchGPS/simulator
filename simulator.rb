# coding: utf-8
require 'socket'
require 'logger'
require 'zlib'

require File.expand_path('../lib/device_simulator', __FILE__)
require File.expand_path('../lib/reading', __FILE__)
require File.expand_path('../lib/misc', __FILE__)
require File.expand_path('../lib/colors', __FILE__)

# Setup the logger
begin
  File.delete(File.expand_path('../log/simulator.log',__FILE__))
rescue
end
logger = Logger.new(File.expand_path('../log/simulator.log',__FILE__))
#logger.datetime_format = "%Y-%m-%d %H:%M:%S"
logger.formatter = proc do |severity, datetime, progname, msg|
  date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
  "[#{date_format}] #{severity.ljust(5)}: #{msg}\n"
end

sims   = []
system "clear" or system "cls"

puts "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯".blue
puts " Calamp Device Simulator".blue
puts "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯".blue

# get simulation options
simulation_mode   = ARGV.shift || get_input("Simulation Mode? (P)layback or (S)imulated", "P")
send_readings     = ARGV.shift || get_input("Send readings to server (Y or N)", "Y")

if send_readings.upcase == "Y"
  # load gateway configurations from config.yml
  load_config
  num_gateways = @gateways.length
  puts "Loaded #{num_gateways} gateway#{'s' if num_gateways > 1}"
  @gateways.each do |g|
    gateway = g[1]
    puts "  starting simultation with server #{gateway[:ip].to_s}:#{gateway[:port].to_s} at #{Time.now}".green
    sims << DeviceSimulator.new(gateway[:ip], gateway[:port])
  end

  trap "SIGINT" do
    # if aborted early, stop the development server
    if sims.length > 0
      puts ""
      sims.each do |sim|
        puts sim.info
        sim.send_message("STOP") if sim.host == "127.0.0.1"
      end
    end
    # exit gracefully
    exit 130
  end
end

if simulation_mode.upcase == "P"
  ################################################################################
  # Playback Simulation
  # Resend the sample dataset in the same time intervals as originally received
  # Original timestamps in the data for update_time and time_of_fix will be updated
  # to match current time.
  ################################################################################

  # Playback mode uses datafiles with millions of readings so we read the file and
  # processes it in realtime as we go
  readings_filename = ARGV.shift || get_input("Readings file", "data/full_day_test.txt.gz")
  if readings_filename.end_with?('gz')
    file_reader = Zlib::GzipReader.open(readings_filename)
  else
    file_reader = File.open(readings_filename)
  end

  # If we want to increase the load we can add a time multiplier
  puts "This simulation is intended to use a full day of data starting at midnight."
  time_skip        = (ARGV.shift || get_input("Do you wish to skip some time? (in hours)", 0)).to_i
  time_multiplier  = (ARGV.shift || get_input("Enter time multiplier (speed-up factor, 1 = real time)", 1)).to_i
  time_multiplier  = 1 if time_multiplier == 0  # prevent division by 0
  compounded_sleep = 0
  reading_count    = 0
  current_second   = Time.now.to_i
  per_second       = 0
  max_per_second   = 0
  logger.info "Playback Mode (skipping #{time_skip} hours at x#{time_multiplier})"

  # The file reader will raise an exception at the end of the file, so we enclose the file
  # processing in a rescue block
  begin

    # get the first reading
    reading = Reading.new(file_reader.readline)

    # if we're skipping some time, do it now
    if time_skip > 0
      print "Skipping ... ".red
      skipped_count = 0
      skip_to = reading.field(:update_time).to_i(16) + (time_skip*60*60)
      while reading.field(:update_time).to_i(16) < skip_to
        skipped_count += 1
        reading = Reading.new(file_reader.readline)
      end
      puts "Skipped #{skipped_count} readings to skip #{time_skip} hours"
    end

    # determine the offset between the current time and the time of the first sample reading
    # all readings will be adjusted by this offset so that the readings are sent at the
    # current time but in the same time intervals as they were originally received
    offset  = Time.now - Time.at(reading.field(:update_time).to_i(16))

    puts "Current | Max/Sec - Sending".blue
    print "\n#{per_second.to_s.rjust(7)} | #{max_per_second.to_s.rjust(7)}   "

    # while we have more readings to process
    while true

      # determine new update_time and time_of_fix based on time offet
      begin
        new_update_time  = (reading.field(:update_time).to_i(16) + offset).to_i.to_s(16)
        reading.set_field_value(:update_time, new_update_time)
      rescue
        puts "Error in update_time: #{reading.field(:update_time)} => #{new_update_time}".red
      end
      
      begin
        new_time_of_fix = (reading.field(:time_of_fix).to_i(16) + offset).to_i.to_s(16)
        reading.set_field_value(:time_of_fix, new_time_of_fix)
      rescue
        puts "Error in time_of_fix: #{reading.field(:time_of_fix)} => #{new_time_of_fix}".red
      end

      # time to wait before sending the next reading
      sleep_time = new_update_time.hex.to_i - Time.now.to_i

      # factor the sleep time by the multiplier
      # since the real time will further away from the adjusted time we need to
      # keep track of how much the time_multiplier has shifted the time and factory
      # that back in as well.
      unless time_multiplier == 1
        sleep_time = sleep_time - compounded_sleep
        compounded_sleep += sleep_time
        sleep_time = sleep_time / time_multiplier
        compounded_sleep -= sleep_time
      end
      
      if sleep_time > 0
        sleep(sleep_time)
      end
      
      if sims.length > 0
        # do a round-robin approach for each available gateway
        reading_count += 1
        sim = sims[reading_count % sims.length]
        sim.send_reading(reading)
      end
      if current_second == Time.now.to_i
        per_second += 1
      else
        max_per_second = per_second if per_second > max_per_second
        print "\n#{per_second.to_s.rjust(7)} | #{max_per_second.to_s.rjust(7)}   "
        per_second = 1
        current_second = Time.now.to_i
      end
      print '#'.green if per_second % 10 == 0
      $stdout.flush

      logger.info reading.data

      reading = Reading.new(file_reader.readline)
    end

  rescue EOFError  #readline raises an EOFError on end of file.
    puts "\ndone!".green
    file_reader.close
  end
  


elsif simulation_mode.upcase == "S"
  ################################################################################
  # Simulated Load
  # Based on specified parameters, data will be sent in at desired rates to
  # allow stress testing
  ################################################################################
  readings_filename = ARGV.shift || get_input("Readings file", "data/simple_test.txt")

  # simulated load loads in a small data set at the beginning and
  # repeatedly loops through it according to the rates calculated by
  # input parameters
  begin
    readings        = Reading.load_file(readings_filename)
  rescue
    puts "Could not load file: #{readings_filename}".red
  exit
  end
  puts ""
  

  now                = Time.now.to_i
  first_reading_time = readings.first.field(:update_time).to_i(16)
  max_offset         = now - first_reading_time

  start_rate         = (ARGV.shift || get_input("Enter starting rate of readings per second", 1)).to_i
  end_rate           = (ARGV.shift || get_input("Enter ending rate of readings per second", 1)).to_i
  max_rate           = (ARGV.shift || get_input("Enter maximum rate of readings per second", 20)).to_i
  ramp_up_time       = (ARGV.shift || get_input("Enter ramp up time in minutes", 2)).to_i
  ramp_down_time     = (ARGV.shift || get_input("Enter ramp down time in minutes", 2)).to_i
  max_duration       = (ARGV.shift || get_input("Enter duration at max rate in minutes", 2)).to_i

  puts "data entry complete".green

  total_duration = ramp_up_time + ramp_down_time + max_duration
  puts "total duration #{total_duration.to_s.red} minutes"

  # calculate ramp up
  ramp_up_seconds    = ramp_up_time * 60
  ramp_up_increase   = (max_rate > start_rate) ? max_rate - start_rate : 0
  ramp_up_ratio      = (ramp_up_seconds > 0) ? ramp_up_increase.to_f / ramp_up_seconds.to_f : 0 
  puts "ramp up ratio #{ramp_up_ratio.to_s.red}"

  # calculate ramp down
  ramp_down_seconds  = ramp_down_time * 60
  ramp_down_decrease = (max_rate > end_rate) ? max_rate - end_rate : 0
  ramp_down_ratio    = (ramp_down_seconds > 0) ? ramp_down_decrease.to_f / ramp_down_seconds.to_f : 0
  puts "ramp down ratio #{ramp_down_ratio.to_s.red}"

  start_time         = Time.now.to_i
  ramp_up_end        = start_time + ramp_up_seconds
  ramp_down_start    = ramp_up_end + (max_duration * 60)
  end_time           = start_time + (total_duration * 60)
  current_time       = start_time
  per_second         = start_rate
  ts_offset          = max_offset - (total_duration * 60)
  reading_counter    = 0

  while current_time < end_time
    current_time    = Time.now.to_i
    elapsed_seconds = current_time - start_time
    
    if current_time < ramp_up_end
      # ramping up
      if ramp_up_ratio == 0
        per_second = start_rate
      elsif ramp_up_ratio < 1
        seconds_between = (1 / ramp_up_ratio).round
        per_second += 1 if per_second < max_rate and elapsed_seconds % seconds_between == 0
      else
        per_second += ramp_up_ratio if per_second < max_rate
      end
    end
    
    if current_time >= ramp_up_end and current_time <= ramp_down_start
      per_second = max_rate
    end
    
    if current_time > ramp_down_start
      ramp_down_elapsed = current_time - ramp_down_start
      # ramping down
      if ramp_down_ratio == 0
        per_second = end_rate
      elsif ramp_down_ratio < 1
        seconds_between = (1 / ramp_down_ratio).round
        per_second -= 1 if per_second > end_rate and ramp_down_elapsed % seconds_between == 0
      else
        per_second -= ramp_down_ratio if per_second > end_rate
      end
    end
    
    per_second_int = per_second.round
    puts "   current rate is #{per_second_int.to_s.red} readings per second" if elapsed_seconds % 30 == 0
    print "    sending: "  
    
    per_second_int.times do
      # send here 
      reading = readings[reading_counter]
      print "#"

      # set the reading times to the current time
      reading.set_field_value(:update_time, Time.now.to_i.to_s(16))
      reading.set_field_value(:time_of_fix, Time.now.to_i.to_s(16))
      
      if sims.length > 0
        sim = sims[reading_counter % sims.length]
        sim.send_reading(reading)
      end

      logger.info reading.data
      
      reading_counter += 1
      reading_counter = 0 if reading_counter >= readings.size
    end
    puts ""
    
    ts_offset += 1 if ts_offset < max_offset
    
    sleep 1
    
  end
end


# stop the development server
if sims.length > 0
  puts ""
  sims.each do |sim|
    puts sim.info
    sim.send_message("STOP") if sim.host == "127.0.0.1"
  end
end

