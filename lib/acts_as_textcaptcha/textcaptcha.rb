require 'yaml'
require 'net/http'
require 'digest/md5'
require 'acts_as_textcaptcha/textcaptcha_cache'
require 'acts_as_textcaptcha/textcaptcha_api'

module ActsAsTextcaptcha

  module Textcaptcha #:nodoc:

    def acts_as_textcaptcha(options = nil)
      cattr_accessor :textcaptcha_config
      attr_accessor  :textcaptcha_question, :textcaptcha_answer, :textcaptcha_key

      # Rails 3, ensure these attrs are accessible
      if respond_to?(:accessible_attributes) && respond_to?(:attr_accessible)
        attr_accessible :textcaptcha_answer, :textcaptcha_key
      end

      validate :validate_textcaptcha, :if => :perform_textcaptcha?

      if options.is_a?(Hash)
        self.textcaptcha_config = options.symbolize_keys!
      else
        begin
          self.textcaptcha_config = YAML.load(File.read("#{Rails.root ? Rails.root.to_s : '.'}/config/textcaptcha.yml"))[Rails.env].symbolize_keys!
        rescue
          raise ArgumentError.new('could not find any textcaptcha options, in config/textcaptcha.yml or model - run rake textcaptcha:config to generate a template config file')
        end
      end

      include InstanceMethods
    end


    module InstanceMethods

      # override this method to toggle textcaptcha checking
      # by default this will only allow new records to be
      # protected with textcaptchas
      def perform_textcaptcha?
        !respond_to?('new_record?') || new_record?
      end

      # generate and assign textcaptcha
      def textcaptcha
        if perform_textcaptcha? && textcaptcha_config
          question = answers = nil

          # get textcaptcha from api
          if textcaptcha_config[:api_key]
            question, answers = TextcaptchaApi.fetch(textcaptcha_config[:api_key], textcaptcha_config)
          end

          # fall back to config based textcaptcha
          unless question && answers
            question, answers = textcaptcha_config_questions
          end

          if question && answers
            assign_textcaptcha(question, answers)
          end
        end
      end


      private

      def textcaptcha_config_questions
        if textcaptcha_config[:questions]
          random_question = textcaptcha_config[:questions][rand(textcaptcha_config[:questions].size)].symbolize_keys!
          [random_question[:question], (random_question[:answers] || '').split(',').map!{ |answer| safe_md5(answer) }]
        end
      end


      # check textcaptcha, if incorrect, regenerate a new textcaptcha
      def validate_textcaptcha
        valid_answers = textcaptcha_cache.read(textcaptcha_key) || []
        reset_textcaptcha
        if valid_answers.include?(safe_md5(textcaptcha_answer))
          # answer was valid, mutate the key again
          self.textcaptcha_key = textcaptcha_random_key
          textcaptcha_cache.write(textcaptcha_key, valid_answers, textcaptcha_cache_options)
          true
        else
          if valid_answers.empty?
            # took too long to answer
            errors.add(:textcaptcha_answer, :expired, :message => 'was not submitted quickly enough, try another question instead')
          else
            # incorrect answer
            errors.add(:textcaptcha_answer, :incorrect, :message => 'is incorrect, try another question instead')
          end
          textcaptcha
          false
        end
      end

      def reset_textcaptcha
        if textcaptcha_key
          textcaptcha_cache.delete(textcaptcha_key)
          self.textcaptcha_key = nil
        end
      end

      def assign_textcaptcha(question, answers)
        self.textcaptcha_question = question
        self.textcaptcha_key      = textcaptcha_random_key
        textcaptcha_cache.write(textcaptcha_key, answers, textcaptcha_cache_options)
      end

      # strip whitespace pass through mb_chars (a multibyte
      # safe proxy for string methods) then downcase
      def safe_md5(answer)
        Digest::MD5.hexdigest(answer.to_s.strip.mb_chars.downcase)
      end

      # a random cache key, time based and random
      def textcaptcha_random_key
        safe_md5(Time.now.to_i + rand(1_000_000))
      end

      def textcaptcha_cache_options
        if textcaptcha_config[:cache_expiry_minutes]
          { :expires_in => textcaptcha_config[:cache_expiry_minutes].to_f.minutes }
        else
          {}
        end
      end

      # cache is used to persist textcaptcha questions and answers
      # between requests
      def textcaptcha_cache
        @@textcaptcha_cache ||= TextcaptchaCache.new
      end
    end
  end
end
