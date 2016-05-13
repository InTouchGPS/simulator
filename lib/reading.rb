require 'json'
require File.expand_path('../colors', __FILE__)

class Reading
  attr_reader :data
  
  # need to keep track of the index and length of all the reading parts
  # a byte is 2 characters in the data

  @@fields = {
    mobile_id_type_length: 1,
    # 0 = off, 1 = esn, 2 = imei, 3 = imsi or sim, 4 = user defined, 5 = phone #, 6 = ipofLMU
    mobile_id_type: 1,
    service_type: 1,
    message_type: 1,
    sequence_number: 2,
    update_time: 4,
    time_of_fix: 4,
    latitude: 4,
    longitude: 4,
    altitude: 4,
    speed: 4,
    heading: 2,
    satellites: 1,
    fix_status: 1,
    carrier: 2,
    rssi: 2,
    comm_state: 1,
    hdop: 1,
    inputs: 1,
    unit_status: 1,
    event_index: 1,
    event_code: 1,
    accum_count: 1,
    spare: 1
  }

  def self.load_file(filename)
    print "Loading #{filename} -"
    count = 0
    return File.open(filename).readlines.collect { |r|
      print "\b"
      count += 1
      case count % 4
      when 0
        print '|'
      when 1
        print '/'
      when 2
        print '-'
      when 3
        print '\\'
      end
      Reading.new(r.chomp!)
    }
  end
  
  def initialize(data)
    @data = data.chomp
    @index = 0
    @positions = {}
    
    length = 2
    @positions[:options_header] = {:index => @index, :length => length}
    @index += length
    
    @positions[:mobile_id_length] = {:index => @index, :length => length}
    @index += length
    
    length = @data[@positions[:mobile_id_length][:index],@positions[:mobile_id_length][:length]].to_i(16) * 2
    
    @positions[:mobile_id] = {:index => @index, :length => length}
    @index += length
    
    @@fields.each do |name,bytes|
      length = bytes * 2
      @positions[name] = {:index => @index, :length => length}
      @index += length
    end

    begin
      acc_count = @data[@positions[:accum_count][:index],@positions[:accum_count][:length]].to_i(16) - 1
      length = 8
      0.upto(acc_count) do |accum|
        @positions["acc_#{accum}".to_sym] = {:index => @index, :length => length}
        @index += length
      end
    rescue
    end
  end
  
  def field(name)
    position = @positions[name]
    if position
      @data[position[:index],position[:length]]
    else
      raise "UNKNOWN FIELD: #{name}"
    end
  end

  def field_value(name)
    value = ""
    
    # convert special formatted values
    if [:update_time, :time_of_fix].include? name
      value = Time.at(field(name).to_i(16)).strftime("%m-%d-%Y %H:%M:%S")
    elsif [:options_header, :mobile_id_type].include? name
      value = field(name).hex.to_s(2).rjust(8, '0')
    elsif [:latitude, :longitude].include? name
      value = (convert_to_signed_twos_complement(field(name).to_i(16), 32) / 1e7).to_s
    else
      begin
        value = field(name).to_i(16).to_s
      rescue
        value = field(name)
      end
    end

    return value
  end    
    
  def set_field_value(name,replacement)
    position = @positions[name]
    if replacement.length <= position[:length]
      @data[position[:index],position[:length]] = replacement.rjust(position[:length], '0')
    else
      throw "SIZE MISMATCH: Could not replace value for #{name.to_s}(#{position[:length].to_s}) with #{replacement}"
    end
  end
  

  def convert_to_signed_twos_complement(integer_value, num_of_bits)
    length       = num_of_bits
    mid          = 2**(length-1)
    max_unsigned = 2**length
    (integer_value >= mid) ? integer_value - max_unsigned : integer_value
  end
  
  def to_h
    object = {}
    @positions.keys.each do |name|
      object[name] = field_value(name)
    end
    return object
  end

  def to_json
    to_h.to_json
  end
      
end
