require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'map'
require 'visibility'

module Ironwood

describe "FieldOfView initialization" do

  before :each do
    @map = StringMap.new [
      "####",
      "#..#",
      "#..#",
      "####",
    ]
  end

  it "should match map size" do
    Visibility::FieldOfView.class_eval("attr_reader :data")
    fov = Visibility::FieldOfView.new @map, 1, 1, DIR_N
    fov.data.length.should == @map.height
    fov.data.first.length.should == @map.width
  end

end

describe "ShadowCasting calculate" do

  it "should render all octants" do
    pending "um"
  end
  
end

end
