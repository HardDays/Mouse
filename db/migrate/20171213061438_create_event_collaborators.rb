class CreateEventCollaborators < ActiveRecord::Migration[5.1]
  def change
    create_table :event_collaborators do |t|
      t.integer :event_id
      t.integer :collaborator_id

      t.timestamps
    end
  end
end
