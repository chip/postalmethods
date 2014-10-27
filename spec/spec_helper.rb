$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'postalmethods'
require 'fakeweb'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

$VERBOSE = nil ##silence annoying warnings from soap4r

PM_OPTS = {:username => 'imajes', :password => 'rubyr00ls', :api_key => ENV['POSTAL_METHODS_API_KEY']}

# hash hacks to make hacking in specs easier
class Hash
  # for excluding keys
  def except(*exclusions)
    self.reject { |key, value| exclusions.include? key.to_sym }
  end

  # for overriding keys
  def with(overrides = {})
    self.merge overrides
  end
end

#require "ruby-debug"
