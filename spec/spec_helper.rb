$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec'
# require 'spec/autorun'
require 'config_reader'
require 'test_config'
require 'sekrets_config'

Spec::Runner.configure do |config|

end
