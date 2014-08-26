class AddParentIds < ActiveRecord::Migration
  def change
    add_column :people, :parent1_id, :integer
    add_column :people, :parent2_id, :integer
  end
end
