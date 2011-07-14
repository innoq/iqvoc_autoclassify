# encoding: UTF-8

require File.join(File.dirname(__FILE__), 'test_helper')

class ParserTest < Test::Unit::TestCase
  
  def setup
  end
  
  test "should split text into sentences" do
    @text = <<-TXT
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod 
      tempor incididunt ut labore et dolore magna aliqua. 
      Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi 
      ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit
      in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur
      sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt
      mollit anim id est laborum.
    TXT
    
    arr = Parser.parse(@text)
    
    puts arr.inspect
    
    assert arr.is_a?(Array)
    assert_equal arr.size, 4
  end
  
end
