# models for use in tests
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Widget < ApplicationRecord
  # uses textcaptcha.yml file for configuration
  acts_as_textcaptcha
end

class Comment < ApplicationRecord
  # inline options (symbol keys) with api_key only
  acts_as_textcaptcha :api_key => '8u5ixtdnq9csc84cok0owswgo'
end

class FastComment < ApplicationRecord
  # inline options with super fast (0.006 seconds) cache expiry time
  acts_as_textcaptcha :cache_expiry_minutes => '0.0001',
                      :questions => [{ :question => '1+1', :answers => '2,two' }]
end

class Review < ApplicationRecord
  # inline options with all possible options
  acts_as_textcaptcha :api_key   => '8u5ixtdnq9csc84cok0owswgo',
                      :questions => [{ :question => 'The green hat is what color?', :answers => 'green' }]
end

class MovieReview < ApplicationRecord
  # inline options with all possible options
  acts_as_textcaptcha 'api_key'   => '8u5ixtdnq9csc84cok0owswgo',
                      'questions' => [{ 'Question' => 'The green hat is what color?', 'answers' => nil }]
end

class Note < ApplicationRecord
  # inline options (string keys) with user defined questions only (no textcaptcha service)
  acts_as_textcaptcha 'questions' => [{ 'question' => '1+1', 'answers' => '2,two' }]

  # allows toggling perform_textcaptcha on/off (default on)
  attr_accessor :turn_off_captcha

  def perform_textcaptcha?
    super && !turn_off_captcha
  end
end

class Contact
  # non active record object (symbol keys), no API used
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActsAsTextcaptcha::Textcaptcha
  acts_as_textcaptcha :questions => [{ :question => 'one+1', :answers => "2,two,апельсин" }]
end

class StrongAccessibleWidget < ApplicationRecord

  # stub out attr_accessbile interface for testing
  def self.accessible_attributes(role = :default); end
  def self.attr_accessible(*args); end

  acts_as_textcaptcha 'questions' => [{ 'question' => '1+1', 'answers' => '2,two' }]
end

class StrongProtectedWidget < StrongAccessibleWidget

  # stub out attr_protected interface for testing
  def self.attr_protected(*args); end

  acts_as_textcaptcha 'questions' => [{ 'question' => '1+1', 'answers' => '2,two' }]
end
