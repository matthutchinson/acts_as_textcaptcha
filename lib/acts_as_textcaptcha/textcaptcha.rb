require 'yaml'
require 'net/http'
require 'digest/md5'

# compatiblity when XmlMini is not available
require 'xml' unless defined?(ActiveSupport::XmlMini)
require 'rexml/document'

# if using as a plugin in /vendor/plugins
begin
  require 'bcrypt'
rescue LoadError => e
  raise "ActsAsTextcaptcha >> please gem install bcrypt-ruby and add `gem \"bcrypt-ruby\"` to your Gemfile (or environment config) #{e}"
end

module ActsAsTextcaptcha

  # dont use Railtie if Rails < 3
  unless Rails::VERSION::MAJOR < 3
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load "tasks/textcaptcha.rake"
      end
    end
  end


  module Textcaptcha #:nodoc:

    # raised if an empty response is ever returned from textcaptcha.com web service
    class BadResponse < StandardError; end;

    def acts_as_textcaptcha(options = nil)
      cattr_accessor :textcaptcha_config
      attr_accessor  :spam_question, :spam_answers, :spam_answer, :skip_textcaptcha

      if respond_to?(:accessible_attributes)
        if accessible_attributes.nil? && respond_to?(:attr_protected)
          attr_protected :spam_question
          attr_protected :skip_textcaptcha
        elsif respond_to?(:attr_accessible)
          attr_accessible :spam_answer, :spam_answers
        end
      end

      validate :validate_textcaptcha

      if options.is_a?(Hash)
        self.textcaptcha_config = options.symbolize_keys!
      else
        begin
          self.textcaptcha_config = YAML.load(File.read("#{Rails.root ? Rails.root.to_s : '.'}/config/textcaptcha.yml"))[Rails.env].symbolize_keys!
        rescue
          raise 'could not find any textcaptcha options, in config/textcaptcha.yml or model - run rake textcaptcha:config to generate a template config file'
        end
      end

      include InstanceMethods
    end


    module InstanceMethods

      # override this method to toggle textcaptcha spam checking altogether, default is on (true)
      def perform_textcaptcha?
        true
      end

      # generate textcaptcha question and encrypt possible spam_answers
      def textcaptcha(use_api = true)
        return if !perform_textcaptcha? || validate_spam_answer
        self.spam_answer = nil

        if textcaptcha_config
          unless BCrypt::Engine.valid_salt?(textcaptcha_config[:bcrypt_salt])
            raise BCrypt::Errors::InvalidSalt.new "you must specify a valid BCrypt Salt in your acts_as_textcaptcha options, get a salt from irb/console with\nrequire 'bcrypt';BCrypt::Engine.generate_salt\n\n(Please check Gem README for more details)\n"
          end
          if textcaptcha_config[:api_key] && use_api
            begin
              uri_parser = URI.const_defined?(:Parser) ? URI::Parser.new : URI # URI.parse is deprecated in 1.9.2
              url = uri_parser.parse("http://textcaptcha.com/api/#{textcaptcha_config[:api_key]}")
              http = Net::HTTP.new(url.host, url.port)
              http.open_timeout = textcaptcha_config[:open_timeout] if textcaptcha_config[:open_timeout]
              http.read_timeout = textcaptcha_config[:read_timeout] if textcaptcha_config[:read_timeout]
              response = http.get(url.path)
              if response.body.empty?
                raise Textcaptcha::BadResponse
              else
                parse_textcaptcha_xml(response.body)
              end
              return
            rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
                   Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, URI::InvalidURIError,
                   REXML::ParseException, Textcaptcha::BadResponse
              # rescue from these errors and continue
            end
          end

          # fall back to textcaptcha_config questions if they are configured correctly
          if textcaptcha_config[:questions]
            random_question = textcaptcha_config[:questions][rand(textcaptcha_config[:questions].size)].symbolize_keys!
            if random_question[:question] && random_question[:answers]
              self.spam_question = random_question[:question]
              self.spam_answers  = encrypt_answers(random_question[:answers].split(',').map!{ |answer| md5_answer(answer) })
            end
          end

          unless self.spam_question && self.spam_answers
            self.spam_question = 'ActsAsTextcaptcha >> no API key (or questions) set and/or the textcaptcha service is currently unavailable (answer ok to bypass)'
            self.spam_answers  = 'ok'
          end
        end
      end


      private

      def parse_textcaptcha_xml(xml)
        if defined?(ActiveSupport::XmlMini)
          parsed_xml = ActiveSupport::XmlMini.parse(xml)['captcha']
          self.spam_question = parsed_xml['question']['__content__']
          if parsed_xml['answer'].is_a?(Array)
            self.spam_answers = encrypt_answers(parsed_xml['answer'].collect { |a| a['__content__'] })
          else
            self.spam_answers = encrypt_answers([parsed_xml['answer']['__content__']])
          end
        else
          parsed_xml         = XML::Parser.string(xml).parse
          self.spam_question = parsed_xml.find('/captcha/question')[0].inner_xml
          self.spam_answers  = encrypt_answers(parsed_xml.find('/captcha/answer').map(&:inner_xml))
        end
      end

      def validate_spam_answer
        (spam_answer && spam_answers) ? spam_answers.split('-').include?(encrypt_answer(md5_answer(spam_answer))) : false
      end

      def validate_textcaptcha
        # only spam check on new/unsaved records (ie. no spam check on updates/edits)
        if !respond_to?('new_record?') || new_record?
          if !skip_textcaptcha && perform_textcaptcha? && !validate_spam_answer
            errors.add(:spam_answer, :incorrect_answer, :message => "is incorrect, try another question instead")
            # regenerate question
            textcaptcha
            return false
          end
        end
        true
      end

      def encrypt_answers(answers)
        answers.map { |answer| encrypt_answer(answer) }.join('-')
      end

      def encrypt_answer(answer)
        BCrypt::Engine.hash_secret(answer, textcaptcha_config[:bcrypt_salt], (textcaptcha_config[:bcrypt_cost].to_i || 10))
      end

      def md5_answer(answer)
        Digest::MD5.hexdigest(answer.to_s.strip.mb_chars.downcase)
      end
    end
  end
end
