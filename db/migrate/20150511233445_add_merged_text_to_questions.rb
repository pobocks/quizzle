class AddMergedTextToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :merged_text, :text, :default => ''
    # If we were using a real DB, we'd index this via fulltext on mysql, or GIN on postgres
    #   Also if I were using a real DB, I'd do the updating in a more complex
    #   but less terrible and slow way, or do it in batches via cronjob, etc.
    #
    #   As is, this will never be run against anything,
    #   because it's been applied before anything is in the DB
    reversible do |dir|
      dir.up do
        Question.all.each do |q|
          q.update_merged_text
          q.save
        end
      end
    end
  end
end
