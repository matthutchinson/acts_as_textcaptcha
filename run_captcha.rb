require 'rails'
require 'acts_as_textcaptcha'


class FiverrEntity
  # # non active record object (symbol keys), no API used
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActsAsTextcaptcha::Textcaptcha

  acts_as_textcaptcha :api_key => '9fubr1exlkcoo84osgs8s4soo3nzs624',
                      :bcrypt_salt => '$2a$10$aGPCeWmh2oibmUHWdb23YO',
                      :questions => [
                        {'question' => 'If Fiverr is the best site ever, which site is the best ever?',
                          'answers' => 'Fiverr, fiverr'},
                        {'question' => "One plus one equals?",
                          'answers' => '2, two'}],
                      :open_timeout => 1,
                      :read_timeout => 1
end


obj = FiverrEntity.new
obj.textcaptcha


p "question =>  #{obj.spam_question}"
