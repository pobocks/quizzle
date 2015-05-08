require 'dotenv'
Dotenv.load

require 'active_record'
ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3",
  :database => "db/quizzle.sqlite3",
  :pool => 5,
  :timeout => 5000
)

require 'pry'
require 'csv'
require 'grape'
require 'sinatra'

require './quizzle'

use ActiveRecord::ConnectionAdapters::ConnectionManagement

run Rack::Cascade.new [Quizzle::API, Quizzle::Web]
