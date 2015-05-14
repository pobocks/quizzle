require './config/environment'
require 'rack/test'
require 'minitest/autorun'
class Quizzle::APITest < Minitest::Test
  include Rack::Test::Methods

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
