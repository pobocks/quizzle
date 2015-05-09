require 'dotenv'
Dotenv.load

require 'pry'
require 'csv'
require 'grape'
require 'sinatra'
require 'sinatra/activerecord'
Dir['./quizzle/**/*.rb'].map { |s| require s.sub(/\.rb\z/, '')}
