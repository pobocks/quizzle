module Quizzle
  class Web < Sinatra::Base
    register Sinatra::ActiveRecordExtension

    USERS = if ENV.key?('BASIC_AUTH_PAIRS')
              ENV['BASIC_AUTH_PAIRS'].split(';').map{|p| p.split(':')}.to_h
            else
              {}
            end

    get '/' do
      headers 'Content-type' => 'text/plain'
      "Hello, world!\n\n" +
        USERS.keys.map {|u|"#{u}"}.join("\n")
    end
  end
end
