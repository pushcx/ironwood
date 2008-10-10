#!/usr/bin/ruby

require 'rubygems'
require 'yaml'
require 'spec'
require 'spec/rake/spectask'

ROOT = File.dirname(__FILE__)

task :default => :spec

desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new() do |t|
  t.spec_opts = ['--options', "\"#{ROOT}/spec/spec.opts\""]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run all specs in spec directory with RCov"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\"#{ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines("#{ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end
  
  desc "Print Specdoc for all specs"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  [:view, :map].each do |sub|
    desc "Run the specs under spec/#{sub}"
    Spec::Rake::SpecTask.new(sub) do |t|
      t.spec_opts = ['--options', "\"#{ROOT}/spec/spec.opts\""]
      t.spec_files = FileList["spec/#{sub}/**/*_spec.rb"]
    end
  end

end
