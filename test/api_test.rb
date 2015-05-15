require './config/environment'
require 'rack/test'
require 'minitest/autorun'

class Quizzle::APITest < Minitest::Test
  include Rack::Test::Methods

  def in_memory_database?
    ENV['RACK_ENV'] == "test" and
      ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLiteAdapter ||
      ActiveRecord::Base.connection.class == ActiveRecord::ConnectionAdapters::SQLite3Adapter and
      ActiveRecord::Base.configurations['test']['database'] == ':memory:'
  end

  def setup
    if in_memory_database?
      puts "creating sqlite in memory database"
      load "db/schema.rb"
    end
  end

  def app
    Quizzle::API
  end

  def test_get_questions
    get "/api/questions"
    assert last_response.ok?
  end

  def test_create_fails_without_key
    post 'api/questions',
         {"question" => "butt?", "answer" => "Yes", "distractors" => ["no"]}.to_json,
         { "CONTENT_TYPE" => "application/json" }
    assert !last_response.ok?
    assert_match /\A401/, JSON.parse(last_response.body)['error']
  end

  def test_delete_fails_without_key
    delete "/api/questions/1"
    assert !last_response.ok?
    assert_match /\A401/, JSON.parse(last_response.body)['error']
  end
end
