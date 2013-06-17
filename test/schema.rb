ActiveRecord::Schema.define(:version => 0) do

  create_table :widgets, :force => true do |t|
    t.string :name
  end

  create_table :comments, :force => true do |t|
    t.string :name
  end

  create_table :reviews, :force => true do |t|
    t.string :name
  end

  create_table :movie_reviews, :force => true do |t|
    t.string :name
  end

  create_table :notes, :force => true do |t|
    t.string :name
  end

  create_table :strong_widgets, :force => true do |t|
    t.string :name
  end
end
