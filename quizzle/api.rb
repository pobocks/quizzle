module Quizzle

  class API < Grape::API
    version 'v1', :using => :header, :vendor => 'Smarterer'
    format :json
    prefix :api

    helpers do
      def authenticate!
        error!('401 Unauthorized', 401) unless headers['X-Api-Key'] == ENV['API_KEY']
      end

      # Adjusts query for pagination, returns [relation, offset, count
      def paginate(rel)
        total = rel.count
        rel = rel.offset(params[:offset]) if params.key?(:offset)
        rel = rel.limit(params[:limit]) if params.key?(:limit)
        count = rel.size
        offset = params.key?(:offset) ? params[:offset] + count : count
        return [rel, total, count, offset]
      end
    end

    resource :questions do
      desc "Index method for questions."
      params do
        optional :limit, type: Integer, values: (0..100)
        optional :offset, type: Integer
      end
      get :index do
        qs = Question.all
        (qs, total, count, offset) = paginate(qs)
        last =  count + offset > total

        {results: qs, status: 'OK', total: total, count: count, offset: offset, last: last  }
      end

      desc "Delete method for questions" do
        headers [XApiKey: {
                   description: 'Valdates that required API key',
                   required: true
                 }]
      end

      params do
        requires :id, :type => Integer, :desc => "Question ID"
      end
      delete ":id" do
        authenticate!
        if q = Question.find_by(:id => params[:id].to_i)
          q.destroy or error!("Destroy failed for ID=#{params[:id]}")
        else
          error!("Record not found.")
        end
      end

    end
  end
end
