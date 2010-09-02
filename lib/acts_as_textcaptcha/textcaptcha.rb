require 'yaml'
require 'net/http'
require 'digest/md5'
require 'logger'

# compatiblity with < Rails 3.0.0
require 'xml' unless defined?(ActiveSupport::XmlMini)

# if using as a plugin in /vendor/plugins
begin
  require 'bcrypt'
rescue LoadError => e
  puts "ActsAsTextcaptcha - please gem install bcrypt-ruby and add `gem \"bcrypt-ruby\"` to your Gemfile (or environment config)"
  raise e
end

module ActsAsTextcaptcha
  module Textcaptcha #:nodoc:

    def acts_as_textcaptcha(options = nil)
      cattr_accessor :textcaptcha_config
      attr_accessor  :spam_answer, :spam_question, :possible_answers
      validate       :validate_textcaptcha

      if options.is_a?(Hash)
        self.textcaptcha_config = options
      else
        begin
          self.textcaptcha_config = YAML.load(File.read("#{Rails.root ? Rails.root.to_s : '.'}/config/textcaptcha.yml"))[Rails.env]
        rescue Errno::ENOENT
          raise('./config/textcaptcha.yml not found')
        end
      end

      include InstanceMethods
    end


    module InstanceMethods

      # override this method to toggle spam checking, default is on (true)
      def perform_spam_check?; true end

      # override this method to toggle allowing the model to be created, default is on (true)
      # if returning false model.validate will always be false with errors on base
      def allowed?; true end

      def validate_textcaptcha
        if new_record?
          if allowed?
            if possible_answers && perform_spam_check? && !validate_spam_answer
              errors.add(:spam_answer, 'is incorrect, try another question instead')
              return false
            end
          else
            errors.add(:base, "Sorry, #{self.class.name.pluralize.downcase} are currently disabled")
            return false
          end
        end
        true
      end

      def validate_spam_answer
        (spam_answer && possible_answers) ? possible_answers.include?(encrypt_answer(Digest::MD5.hexdigest(spam_answer.strip.downcase.to_s))) : false
      end

      def encrypt_answers(answers)
        answers.map {|answer| encrypt_answer(answer) }
      end

      def encrypt_answer(answer)
        return answer unless(textcaptcha_config['bcrypt_salt'])
        BCrypt::Engine.hash_secret(answer, textcaptcha_config['bcrypt_salt'], (textcaptcha_config['bcrypt_cost'].to_i || 10))
      end

      def generate_spam_question(use_textcaptcha = true)
        if use_textcaptcha && textcaptcha_config && textcaptcha_config['api_key']
          begin
            resp = Net::HTTP.get(URI.parse('http://textcaptcha.com/api/'+textcaptcha_config['api_key']))
            return [] if resp.empty?

            if defined?(ActiveSupport::XmlMini)
              parsed_xml = ActiveSupport::XmlMini.parse(resp)['captcha']
              self.spam_question    = parsed_xml['question']['__content__']
              if parsed_xml['answer'].is_a?(Array)
                self.possible_answers = encrypt_answers(parsed_xml['answer'].collect {|a| a['__content__']})
              else
                self.possible_answers = encrypt_answers([parsed_xml['answer']['__content__']])
              end
            else
              parsed_xml            = XML::Parser.string(resp).parse
              self.spam_question    = parsed_xml.find('/captcha/question')[0].inner_xml
              self.possible_answers = encrypt_answers(parsed_xml.find('/captcha/answer').map(&:inner_xml))
            end
            return possible_answers if spam_question && !possible_answers.empty?
          rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ECONNREFUSED,
                 Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, URI::InvalidURIError => e
            log_textcaptcha("failed to load or parse textcaptcha with key '#{textcaptcha_config['api_key']}'; #{e}")
          end
        end

        # fall back to textcaptcha_config questions
        if textcaptcha_config && textcaptcha_config['questions']
          log_textcaptcha('falling back to random logic question from config') if textcaptcha_config['api_key']
          random_question       = textcaptcha_config['questions'][rand(textcaptcha_config['questions'].size)]
          self.spam_question    = random_question['question']
          self.possible_answers = encrypt_answers(random_question['answers'].split(',').map!{|ans| Digest::MD5.hexdigest(ans)})
        end
        possible_answers
      end

      private
      def log_textcaptcha(message)
        logger ||= Logger.new(STDOUT)
        logger.info "Textcaptcha >> #{message}"
      end
    end
  end
end