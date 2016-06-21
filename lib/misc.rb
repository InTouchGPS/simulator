require 'yaml'
require File.expand_path('../colors', __FILE__)

def load_config
  config = YAML.load_file('config.yml')
  gateway_count = (config['gateway']['count']).to_i
  @gateways = {}
  for i in 1..gateway_count
    @gateways[i] = {
      :ip => config['gateway']["gateway#{i}"]['ip'],
      :port => config['gateway']["gateway#{i}"]['port']
    }
  end
  @debug = config['system']['debug']

  @database = config['database']

  @queue = config['queue']
end

def get_input(message, default)
  print "#{message} (default: #{default.to_s.blue}): "
  value =  gets.chomp
  return default if value.empty?
  value
end
