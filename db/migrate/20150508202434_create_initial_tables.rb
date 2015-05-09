class CreateInitialTables < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :value, :null => false
      t.timestamps
    end

    create_table :answers do |t|
      t.string :value, :null => false
      t.references :question
      t.timestamps
    end

    create_table :distractors do |t|
      t.string :value
      t.references :question
      t.timestamps
    end
  end
end
