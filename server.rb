# coding: utf-8
require 'socket'
require 'mysql2'
require 'time'
require 'logger'

require File.expand_path('../lib/reading', __FILE__)
require File.expand_path('../lib/colors', __FILE__)
require File.expand_path('../lib/misc', __FILE__)

system "clear" or system "cls"
puts "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯".blue
puts " Calamp Gateway Simulator".blue
puts "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯".blue

begin
  load_config

  #
  # Open Port
  #
  port = ARGV.shift || get_input("Port for this Gateway?", 1234)
  s = UDPSocket.new
  begin
    s.bind(nil, port)
    puts "Listening on port #{port}".green
  rescue
    puts "Could not bind to port #{port}.".red
    exit
  end

  #
  # Set up log file
  #
  begin
    File.delete(File.expand_path("../log/server-#{port}.log",__FILE__))
  rescue
  end
  logger = Logger.new(File.expand_path("../log/server-#{port}.log",__FILE__))
  #logger.datetime_format = "%Y-%m-%d %H:%M:%S"
  logger.formatter = proc do |severity, datetime, progname, msg|
    date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
    "[#{date_format}] #{severity.ljust(5)}: #{msg}\n"
  end
  
  #
  # If logging messages to database, connect to DB
  #
  log_to_db = (ARGV.shift || get_input("Log to database (Y or N)?", "Y")).upcase
  if log_to_db == "Y"
    begin
      # connect to the MySQL server
      client = Mysql2::Client.new(@database)
      # get server version string and display it
      puts "Connected to MySQL server version: #{client.server_info[:version].blue}"
      logger.info "Connected to MySQL server version: #{client.server_info[:version]}"
      
      # Give option to clear out prior messages from DB
      results = client.query("SELECT COUNT(*) as message_count FROM messages")
      message_count = results.first['message_count'].to_i
      if message_count > 0
        ok_to_purge = ARGV.shift || get_input("OK to purge #{message_count.to_s.cyan} existing messages (Y or N)?", "Y")
        
        if ok_to_purge == "Y"
          puts "Clearing out messages table"
          client.query("TRUNCATE messages")
          logger.info "Purged message table"
        end
      else
        puts "No prior messages to purge."
      end
      
      insert_statement = client.prepare("INSERT INTO messages (update_time, fix_time, received_at, msg_type, lat, lng, device_id, speed, direction, altitude, satellites, fix_status, event_code, event_index, hdop, comm_state, rssi, netwrk_id, inputs, unit_status, seq_num, msg_route, msg_id, app_msg_type, user_msg, app_msg, mobile_id, raw_data, accumulator_count, accumulator_0, accumulator_1, accumulator_2, accumulator_3, accumulator_4, accumulator_5, accumulator_6, accumulator_7, accumulator_8, accumulator_9, accumulator_10, accumulator_11, accumulator_12, accumulator_13, accumulator_14, accumulator_15, accumulator_16, accumulator_17, accumulator_18, accumulator_19, accumulator_20, accumulator_21, accumulator_22, accumulator_23, accumulator_24, accumulator_25, accumulator_26, accumulator_27, accumulator_28, accumulator_29, accumulator_30, accumulator_31 ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)")

    rescue Mysql2::Error => e
      puts "Database Error".red
      puts "Error code:    #{e.error_number} SQL_STATE(#{e.sql_state})"
      puts "Error message: #{e.message}"
      logger.error e
    end
  end
  
  total_readings_received = 0
  start_time = Time.now
  puts "Started at #{start_time}.  Waiting to receive."
  logger.info "Started ... waiting to receive."
  current_second = start_time.to_i
  current_second_readings = 0
  max_per_second = 0

  #
  # main loop to receive messages
  #
  while true
    if Time.now.to_i > current_second
      logger.info "RECEVING #{current_second_readings}/second"
      print "\rRECEVING #{current_second_readings}/second".green
      $stdout.flush
      max_per_second = current_second_readings if current_second_readings > max_per_second
      current_second_readings = 0
      current_second = Time.now.to_i
    end
    
    text, sender = s.recvfrom(65536)
    break if text == "STOP"
    
    reading = Reading.new(text)
    current_second_readings += 1
    total_readings_received += 1
    
    if log_to_db == "Y"
      begin
        # Save the reading to the messages table
        accum_count = reading.field_value(:accum_count).to_i
        insert_statement.execute(
          Time.strptime(reading.field_value(:update_time), "%m-%d-%Y %H:%M:%S"),
          Time.strptime(reading.field_value(:time_of_fix), "%m-%d-%Y %H:%M:%S"),
          Time.now,
          reading.field_value(:message_type).to_i,
          reading.field_value(:latitude).to_f,
          reading.field_value(:longitude).to_f,
          reading.field_value(:mobile_id).to_i,
          reading.field_value(:speed).to_f,
          reading.field_value(:heading).to_f,
          reading.field_value(:altitude).to_f,
          reading.field_value(:satellites).to_i,
          reading.field_value(:fix_status).to_i,
          reading.field_value(:event_code).to_i,
          reading.field_value(:event_index).to_i,
          reading.field_value(:hdop).to_f,
          reading.field_value(:comm_state).to_i,
          reading.field_value(:rssi).to_i,
          reading.field_value(:carrier).to_i,
          reading.field_value(:inputs).to_i,
          reading.field_value(:unit_status).to_i,
          reading.field_value(:sequence_number).to_i,
          nil, #msg_route
          nil, #msg_id
          nil, #app_msg_type
          nil, #user_msg
          nil, #app_msg
          reading.field_value(:mobile_id),
          reading.data,
          accum_count,
          accum_count >= 1 ? reading.field_value(:acc_0) : nil,
          accum_count >= 2 ? reading.field_value(:acc_1) : nil,
          accum_count >= 3 ? reading.field_value(:acc_2) : nil,
          accum_count >= 4 ? reading.field_value(:acc_3) : nil,
          accum_count >= 5 ? reading.field_value(:acc_4) : nil,
          accum_count >= 6 ? reading.field_value(:acc_5) : nil,
          accum_count >= 7 ? reading.field_value(:acc_6) : nil,
          accum_count >= 8 ? reading.field_value(:acc_7) : nil,
          accum_count >= 9 ? reading.field_value(:acc_8) : nil,
          accum_count >= 10 ? reading.field_value(:acc_9) : nil,
          accum_count >= 11 ? reading.field_value(:acc_10) : nil,
          accum_count >= 12 ? reading.field_value(:acc_11) : nil,
          accum_count >= 13 ? reading.field_value(:acc_12) : nil,
          accum_count >= 14 ? reading.field_value(:acc_13) : nil,
          accum_count >= 15 ? reading.field_value(:acc_14) : nil,
          accum_count >= 16 ? reading.field_value(:acc_15) : nil,
          accum_count >= 17 ? reading.field_value(:acc_16) : nil,
          accum_count >= 18 ? reading.field_value(:acc_17) : nil,
          accum_count >= 19 ? reading.field_value(:acc_18) : nil,
          accum_count >= 20 ? reading.field_value(:acc_19) : nil,
          accum_count >= 21 ? reading.field_value(:acc_20) : nil,
          accum_count >= 22 ? reading.field_value(:acc_21) : nil,
          accum_count >= 23 ? reading.field_value(:acc_22) : nil,
          accum_count >= 24 ? reading.field_value(:acc_23) : nil,
          accum_count >= 25 ? reading.field_value(:acc_24) : nil,
          accum_count >= 26 ? reading.field_value(:acc_25) : nil,
          accum_count >= 27 ? reading.field_value(:acc_26) : nil,
          accum_count >= 28 ? reading.field_value(:acc_27) : nil,
          accum_count >= 29 ? reading.field_value(:acc_28) : nil,
          accum_count >= 30 ? reading.field_value(:acc_29) : nil,
          accum_count >= 31 ? reading.field_value(:acc_30) : nil,
          accum_count == 32 ? reading.field_value(:acc_31) : nil 
        )
      rescue Mysql2::Error => e
        puts "Database Error".red
        puts "Error code:    #{e.error_number} SQL_STATE(#{e.sql_state})"
        puts "Error message: #{e.message}"
        logger.error e
      end

    else  # No logging to DB
      logger.info "RECEIVED [#{sender[3]} / #{Time.now}]: #{text}"
      logger.info reading.to_h
    end
  end
  
  result = "#{'STOPPED:'.red} received #{total_readings_received} readings at a maximum of #{max_per_second}/sec.  #{'Server uptime:'.green} #{Time.now - start_time} seconds"
  puts "\r#{result}"
  logger.info result
  
ensure
  # disconnect from database
  client.close if client
end


