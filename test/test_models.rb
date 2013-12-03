# coding: utf-8
# models for use in tests

class Widget < ActiveRecord::Base
  # uses textcaptcha.yml file for configuration
  acts_as_textcaptcha
end

class Comment < ActiveRecord::Base
  # inline options (symbol keys) with api_key only
  acts_as_textcaptcha :api_key     => '8u5ixtdnq9csc84cok0owswgo',
                      :bcrypt_salt => '$2a$10$j0bmycH.SVfD1b5mpEGPpe'
end

class Review < ActiveRecord::Base
  # inline options with all possible options
  acts_as_textcaptcha :api_key     => '8u5ixtdnq9csc84cok0owswgo',
                      :bcrypt_salt => '$2a$10$j0bmycH.SVfD1b5mpEGPpe',
                      :bcrypt_cost => '3',
                      :questions   => [{ :question => 'The green hat is what color?', :answers => 'green' }]
end

class MovieReview < ActiveRecord::Base
  # inline options with all possible options
  acts_as_textcaptcha 'api_key'     => '8u5ixtdnq9csc84cok0owswgo',
                      'bcrypt_salt' => '$2a$10$j0bmycH.SVfD1b5mpEGPpe',
                      'bcrypt_cost' => '3',
                      'questions'   => [{ 'Question' => 'The green hat is what color?', 'answers' => nil }]
end

class Note < ActiveRecord::Base
  # inline options (string keys) with user defined questions only (no textcaptcha service)
  acts_as_textcaptcha 'questions'   => [{ 'question' => '1+1', 'answers' => '2,two' }],
                      'bcrypt_salt' => '$2a$10$j0bmycH.SVfD1b5mpEGPpe'

  # allows toggling perform_textcaptcha on/off (default on)
  attr_accessor :turn_off_captcha

  def perform_textcaptcha?
    !turn_off_captcha
  end
end

class Contact
  # non active record object (symbol keys), no API used
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActsAsTextcaptcha::Textcaptcha
  acts_as_textcaptcha :questions   => [{ :question => 'one+1', :answers => "2,two,апельсин" }],
                      :bcrypt_salt => '$2a$10$j0bmycH.SVfD1b5mpEGPpe'
end

# ActiveRecord model using the strong parameters gem
require 'strong_parameters'

class StrongWidget < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection
  acts_as_textcaptcha 'questions'   => [{ 'question' => '1+1', 'answers' => '2,two' }],
                      'bcrypt_salt' => '$2a$10$j0bmycH.SVfD1b5mpEGPpe'
end
