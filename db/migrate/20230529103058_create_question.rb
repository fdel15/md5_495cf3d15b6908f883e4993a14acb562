class CreateQuestion < ActiveRecord::Migration[7.0]
  def change
    create_table :questions, id: false do |t|
      t.string :id, limit: 36, primary_key: true
      t.text :query_text, null: false
      t.text :answer_text, null: false
      t.string :md5_hash, limit: 32, null: false
      t.integer :number_of_times_asked, default: 1
      t.timestamps
    end

    add_index :questions, :md5_hash
  end
end
