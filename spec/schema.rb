ActiveRecord::Schema.define(:version => 0) do

  create_table :comments, :force => true do |t|
    t.string :name
  end
end