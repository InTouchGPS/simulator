require File.expand_path('../colors', __FILE__)

class DeviceSimulator
  attr_reader :host, :port, :readings_sent
  
  def initialize(host, port)
    @host                  = host
    @port                  = port
    @socket                = UDPSocket.new
    @readings_sent         = 0
    @first_reading_sent_at = nil
  end

  def send_reading(reading)
    @first_reading_sent_at = Time.now if @first_reading_sent_at.nil?

    if reading.kind_of? Reading
      send_message(reading.data)
    else
      send_message(reading)
    end

    @readings_sent += 1
  end

  def send_message(msg)
    @socket.send(msg, 0, @host, @port)
  end
  
  def info
    if @first_reading_sent_at.nil?
      "No reading sent yet".red
    else
      "Sent #{@readings_sent.to_s.red} readings to #{host}:#{@port} in #{Time.now - @first_reading_sent_at} seconds"
    end
  end
end
