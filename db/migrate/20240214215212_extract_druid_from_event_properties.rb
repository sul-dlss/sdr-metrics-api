class ExtractDruidFromEventProperties < ActiveRecord::Migration[7.1]
  def change
    # Add a druid column to the events table with index
    add_column :ahoy_events, :druid, :string
    add_index :ahoy_events, :druid

    # Populate the new column using existing data in properties text field
    reversible do |direction|
      direction.up do
        Ahoy::Event.find_each do |event|
          event.update!(druid: event.properties['druid'])
        end
      end
      direction.down do
        # no-op
      end
    end
  end
end
