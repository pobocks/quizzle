require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require './config/environment'
  end
end

namespace :quizzle do

  desc "Simple console - pry in context of application"
  task :console do
    require './config/environment'
    binding.pry
  end

  task :import do
    require './config/environment'
    require 'csv'
    unless ENV['CSV']
      p "Please provide a CSV to import via the CSV environment variable."
      exit
    end

    csv = CSV.new(File.open(ENV['CSV']),
                  col_sep: '|', headers: true)

    ActiveRecord::Base.connection.transaction do
      csv.each do |row|
        Question.create(value: row['question'],
                        answer: Answer.new(value: row['answer']),
                        distractors: row['distractors'].split(/(?<!\\),\s*/).map {|d|
                          Distractor.new(value: d.gsub(/\\,/, ','))
                        })
      end
    end
  end
end
