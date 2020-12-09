class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries do |t|
      t.string :timestamp
      t.string :status
      t.references :lock, null: false, foreign_key: true, type: :string

      t.timestamps
    end
  end
end
