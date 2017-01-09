require_relative 'service/base'
require_relative 'service/facebook'
require_relative 'service/twitter'
require_relative 'service/linkedin'
require_relative 'service/google_plus'
require_relative 'service/instagram'

module SocialMedia::Service
  def self.service_classes
    ObjectSpace.each_object(Class).select { |klass| klass < SocialMedia::Service::Base }
  end

  def self.services
    service_classes.map(&:name)
  end

  def self.service name
    service_classes.detect{ |d| d.name == name.to_sym }
  end

  def self.method_missing method_sym, *arguments
    if service_by_name = service(method_sym)
      return service_by_name if arguments.empty?
      service_by_name.new *arguments
    else
      super
    end
  end
end
