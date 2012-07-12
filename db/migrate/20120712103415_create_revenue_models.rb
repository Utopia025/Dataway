class CreateRevenueModels < ActiveRecord::Migration
  def change
    create_table :revenue_models do |t|
      t.string :ent_id
      t.string :company
      t.decimal :revenue_mill
      t.string :source
      t.datetime :updated_at
      t.string :updated_by
      t.boolean :is_verified

      t.timestamps
    end
  end
end
