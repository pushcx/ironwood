require 'rubygems'
require 'yaml'

$:.unshift File.join(File.dirname(__FILE__), "..")
require 'constants'

FIXTURES_DIR = File.join(File.dirname(__FILE__), "fixtures")

#def load_fixture type, name
#  YAML::load_file("#{FIXTURES_DIR}/#{type}.yaml")[name.to_s]
#end

#def fixtures name
#  puts Spec::Example::ExampleGroup.methods.sort
#  Spec::Example::ExampleGroup.each do |c|
#    puts c
#    c.class_eval <<-end_eval
#      def #{name} which
#        YAML::load_file("#{FIXTURES_DIR}/#{name}.yaml")[which.to_s]
#      end
#    end_eval
#  end
#end
