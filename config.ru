require './config/environment'

use ActiveRecord::ConnectionAdapters::ConnectionManagement

run Rack::Cascade.new [Quizzle::API, Quizzle::Web]
