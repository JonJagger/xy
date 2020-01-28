$stdout.sync = true
$stderr.sync = true

require_relative 'xy'
require 'rack'
run XY.new(nil)
