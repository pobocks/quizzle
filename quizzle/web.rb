module Quizzle
  class Web < Sinatra::Base
    register Sinatra::ActiveRecordExtension
    set :haml, :format => :html5

    USERS = if ENV.key?('BASIC_AUTH_PAIRS')
              ENV['BASIC_AUTH_PAIRS'].split(';').map{|p| p.split(':')}.to_h
            else
              {}
            end

    get '/' do
      @qs = Question.all.limit(10)
      @qs = @qs.order(:id => :desc) if params.key? 'reverse'
      if params["skip"]
        @offset = params["skip"].to_i * 10
        @qs = @qs.offset(offset)
      end

      haml :index
    end
  end
end
