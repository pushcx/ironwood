require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'map'

module Ironwood

describe 'simple map loading' do

  before(:each) do
    @map = StringMap.new(['.'])
  end

  it "should load the simplest map" do
    @map = StringMap.new(['.'])
  end

  it "should be very thin" do
    @map.width.should == 1
  end

  it "should be very short" do
    @map.height.should == 1
  end
end

describe "tile test map" do

  before(:each) do
    @map = StringMap.new([
      '.+',
      '~#',
    ])
  end

  it "should return tiles" do
    pending "creation of Terrain and Tile"
    # remove next test when this is in
  end

  it "should return characters for tiles" do
    @map.tile(0, 0).class.should == String
    @map.tile(0, 0).length.should == 1
  end

  it "should regard x < 0 as exceptional"      do ; lambda { @map.tile(-1, 0) }.should raise_error(IndexError) ; end
  it "should regard y < 0 as exceptional"      do ; lambda { @map.tile(-1, 0) }.should raise_error(IndexError) ; end
  it "should regard x > width as exceptional"  do ; lambda { @map.tile(0, @map.width  + 1) }.should raise_error(IndexError) ; end
  it "should regard y > height as exceptional" do ; lambda { @map.tile(0, @map.height + 1) }.should raise_error(IndexError) ; end

  it "should treat # as blocking visibility" do ; @map.blocks_visibility?(1, 1).should be_true ; end
  it "should treat + as blocking visibility" do ; @map.blocks_visibility?(1, 0).should be_true ; end
  it "should treat ~ as allowing visibility" do ; @map.blocks_visibility?(0, 1).should be_false ; end
  it "should treat . as allowing visibility" do ; @map.blocks_visibility?(0, 0).should be_false ; end
  it "should treat # as blocking movement"   do ; @map.blocks_movement?(1, 1).should be_true ; end
  it "should treat + as allowing movement"   do ; @map.blocks_movement?(1, 0).should be_false ; end
  it "should treat ~ as blocking movement"   do ; @map.blocks_movement?(0, 1).should be_true ; end
  it "should treat . as allowing movement"   do ; @map.blocks_movement?(0, 0).should be_false ; end

  it "should display correctly" do
    pending "the patience to write this test - and maybe fov changes"
  end

end

describe 'demo dungeon' do

  before(:each) do
    @map = StringMap.new([
      "##################################################",
      "#..#.........#.#.................................#",
      "#..#..#......###.................................#",
      "#.....#......................#####......#........#",
      "#######......................~~~~#......#........#",
      "#........................~~~~~..~#...............#",
      "#.................~~~~~~~~~......................#",
      "#................~~~~~~..........................#",
      "#........#.......~~~~..................###+###...#",
      "########+#..##....~~~...#..............#.....#...#",
      "#........#.........~~....#.............#.....+...#",
      "#........#........~~......#............#+#####...#",
      "#........#.......~~..............................#",
      "##################################################"
    ])
  end

  it "should load width" do
    @map.width.should == 50
  end

  it "should load height" do
    @map.height.should == 14
  end

end

end
