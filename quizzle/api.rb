# coding: utf-8
module Quizzle

  class API < Grape::API
    cascade false
    version 'v1', :using => :header, :vendor => 'Smarterer'
    format :json
    prefix :api

    MAX_RECORDS = ENV['MAX_RECORDS'] || 100

    helpers do
      def authenticate!
        error!('401 Unauthorized', 401) unless headers['X-Api-Key'] == ENV['API_KEY']
      end

      params :pagination do
        optional :limit, type: Integer, values: (0..MAX_RECORDS), default: 10
        optional :offset, type: Integer, default: 0
        optional :reverse, type: Boolean, default: false
      end

      params :id do
        requires :id, type: Integer, regexp: /\A\d+\z/, desc: "Question ID"
      end

      params :question_vals do
        requires :question, type: String, desc: "Question text"
        requires :answer, type: String, desc: "Answer text"
        requires :distractors, type: Array, desc: "Array of distractor texts"
      end

      def qvals
        {value: params[:question],
         answer_attributes: {value: params[:answer]},
         distractors_attributes: params[:distractors].map {|d|
           {value: d}
         }
        }
      end

      # Adjusts query for pagination, returns [relation, offset, count
      def paginate(rel)
        total = rel.count
        rel = rel.order(id: :desc) if params[:reverse]
        rel = rel.offset(params[:offset]) if params.key?(:offset)
        rel = rel.limit(params[:limit])
        count = rel.size
        offset = params.key?(:offset) ? params[:offset] + count : count
        return [rel, total, count, offset]
      end
    end

    resource :questions do
      # Collection methods

      desc "Index method for questions."
      params do
        use :pagination
      end
      get '/' do
        qs = Question.includes(:answer, :distractors)
        (qs, total, count, offset) = paginate(qs)
        last =  params[:limit] + offset > total

        {results: qs, status: 'OK', total: total, count: count, offset: offset, last: last  }
      end

      desc "Search method for questions - searches across question text and values"
      params do
        use :pagination
        requires :q, type: String
        optional :field, type: String, values: %w|questions answers distractors|
      end
      get :search do
        # We use vertical tabs as a separator in the DB, because
        #   they have basically no other use, and should not be found in CSV files
        #
        # It's unlikely that they'll show up in user submission, but we should drop them just in case.
        params[:q] = "%" << params[:q].gsub(/\v/, '') + "%"
        qs = Question.joins(:answer, :distractors)
        if params[:field]
          qs = qs.where("?.value LIKE ?", params[:field], params[:q])
        else
          qs = qs.where("merged_text LIKE ?", params[:q])
        end
        (qs, total, count, offset) = paginate(qs)
        last = params[:limit] + offset > total

        {results: qs, status: 'OK', total: total, count: count, offset: offset, last: last  }
      end

      # Member methods
      desc "Read method for questions"
      params do
        requires :id, type: Integer, regexp: /\A\d+\z/, desc: "Question ID"
      end
      get ":id" do
        if q = Question.find_by(:id => params[:id])
          {result: q, status: 'OK'}
        else
          # Should be 404, but those cascade to Sinatra regardless of cascade setting in Grape ¯\_(ツ)_/¯
          error!({error: "Question not found."}, 200, { 'Content-Type' => 'application/json' } )
        end
      end

      desc "Create method for questions" do
        headers [XApiKey: {
                   description: 'Validates that required API key is present',
                   required: true
                 }]
      end
      params do
        use :question_vals
      end
      post "/" do
        authenticate!
        q = Question.create(qvals)
        {result: q, status: 'OK', created: true}
      end

      desc "Update method for questions" do
        headers [XApiKey: {
                   description: 'Validates that required API key is present',
                   required: true
                 }]
      end
      params do
        use :id
        use :question_vals
      end
      put ":id" do
        authenticate!
        if q = Question.find_by(:id => params[:id])
          success = nil
          Question.transaction do
            q.distractors.delete_all
            q.update(qvals)

            success = q.save or raise ActiveRecord::Rollback
          end
          if success
            {result: q, status: 'OK', updated: true}
          else
            error!("Update failed for ID=#{params[:id]}")
          end
        else
          error!({error: "ID=#{params[:id]} not found for update"}, 200, { 'Content-Type' => 'text/error' })
        end
      end

      desc "Delete method for questions" do
        headers [XApiKey: {
                   description: 'Validates that required API key is present',
                   required: true
                 }]
      end
      params do
        use :id
      end
      delete ":id" do
        authenticate!
        if q = Question.find_by(:id => params[:id])
          q.destroy or error!("Destroy failed for ID=#{params[:id]}")
          {result: q, status: 'OK', destroyed: true}
        else
          error!({error: "ID=#{params[:id]} not found for delete."}, 200, { 'Content-Type' => 'text/error' } )
        end
      end
    end

    # Catchall route to (in an ideal world where cascade: false works) prevent
    #   API 404s from getting handled by Sinatra
    route :any, '*path' do
      error!("URI not found") # or something else
    end
  end
end
