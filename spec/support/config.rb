require 'yaml'

def symbolized_keys hash
  hash.keys.each do |key|
    hash[(key.to_sym rescue key) || key] = hash.delete(key)
  end
  hash.each_pair{|k,v| hash[k] = symbolized_keys(v) if v.is_a?(Hash)}
  return hash
end

def service_configurations
  config_path = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config'))
  @service_configurations ||= symbolized_keys YAML::load_file(File.join(config_path, 'services.yml'))
end

def service_configured? name
  !!service_configurations[name.to_sym]
end
