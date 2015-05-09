require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require './config/environment'
  end
end

task :console do
  require './config/environment'
  binding.pry
end
