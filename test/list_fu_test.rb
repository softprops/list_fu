require File.join(File.dirname(__FILE__), 'test_helper')
require 'action_controller'
require 'action_controller/test_process'
require 'list_fu'

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

ActionController::Base.perform_caching = false

class ListFuTest < Test::Unit::TestCase
  
  # Controller that responds to requests for lists of numbers.
  # Didn't need to test active record objects so I used 
  # fixnum's for a lighter weight test. This gets around rendering 
  # list_of in the view by rendering inline text for the source.
  class TasksController < ActionController::Base
  
    def list_unordered_numbers
      @numbers = (1..3).to_a
      render :inline => '<% list_of @numbers do |number| %><%= number %><% end %>'
    end
    
    def list_ordered_numbers
      @numbers = (1..3).to_a
      render :inline => '<% list_of @numbers, {:ordered=>true} do |number| %><%= number %><% end %>'
    end
    
    def list_numbers_options
      @numbers = (1..3).to_a
      render :inline => '<% list_of @numbers, {:ordered=>true,:class=>"clearfix",:id=>"list_of_numbers"},{:class=>"test"} do |number| %><%= number %><% end %>'
    end

    protected
    def rescue_errors(e) raise e end
    def rescue_action(e) raise e end
    
  end
  
  def setup
    @controller = TasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    super
  end
  
  def test_should_render_unordered_list_of_numbers
    get :list_unordered_numbers
    entries = assigns :numbers
    assert entries
    assert_select 'ul#fixnum_list', 1, 'no list here' do |el|
      assert_select 'li.fixnum', 3
    end
  end
  
  def test_should_render_ordered_list_of_numbers
    get :list_ordered_numbers
    entries = assigns :numbers
    assert entries
    assert_select 'ol#fixnum_list', 1, 'no list here' do |el|
      assert_select 'li.fixnum', 3
    end
  end
  
  def test_should_render_with_options
    get :list_numbers_options
    entries = assigns :numbers
    assert entries
    assert_select 'ol.clearfix', 1
    assert_select 'ol#list_of_numbers', 1, 'no list here' do |el|
      assert_select 'li.test'
    end
  end
  
end
