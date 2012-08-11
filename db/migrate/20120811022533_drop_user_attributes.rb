class DropUserAttributes < ActiveRecord::Migration
  def up
    User.new.attributes.keys.each do |key|
      puts "removing #{key}"
      unless key == "id"
        remove_column :users, key.to_sym
      end
    end
  end

  def down
  end
end
