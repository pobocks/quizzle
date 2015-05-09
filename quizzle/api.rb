module Quizzle
  class API < Grape::API
    version 'v1', :using => :header, :vendor => 'Smarterer'
    format :json
    prefix :api

    helpers do
      def authenticate!
        error!('401 Unauthorized', 401) unless params['api-key'] == ENV['API_KEY']
      end
    end

    desc "Shamelessly expose API Key"
    params do
      requires 'api-key'
    end
    get 'gimme-key' do
      authenticate!
      {:key => ENV['API_KEY']}
    end

    resource :hellos do
      desc "Hiya"
      get :hello_world do
	      CSV.new(File.read('smarterer_code_challenge_question_dump.csv')).first.to_s
      end
    end
  end
end
