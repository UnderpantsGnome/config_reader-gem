$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "config_reader"
require "test_config"
require "sekrets_config"
require "no_key_no_error_config"

ENV["RACK_ENV"] = "test"
ENV["SEKRETS_KEY"] = "bb9e65113e80605f1f7c"
