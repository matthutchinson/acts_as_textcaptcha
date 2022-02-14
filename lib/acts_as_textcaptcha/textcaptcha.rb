# frozen_string_literal: true

require "yaml"
require "net/http"
require "digest/md5"
require "acts_as_textcaptcha/textcaptcha_cache"
require "acts_as_textcaptcha/textcaptcha_api"

module ActsAsTextcaptcha
  module Textcaptcha
    def acts_as_textcaptcha(options = nil)
      cattr_accessor :textcaptcha_config
      attr_accessor :textcaptcha_question, :textcaptcha_answer, :textcaptcha_key

      # ensure these attrs are accessible (Rails 3)
      attr_accessible :textcaptcha_answer, :textcaptcha_key if respond_to?(:accessible_attributes) && respond_to?(:attr_accessible)

      self.textcaptcha_config = build_textcaptcha_config(options).symbolize_keys!

      validate :validate_textcaptcha, if: :perform_textcaptcha?

      include InstanceMethods
    end

    module InstanceMethods
      # override this method to toggle textcaptcha checking, by default this
      # will only allow new records to be protected with textcaptchas
      def perform_textcaptcha?
        (!respond_to?("new_record?") || new_record?)
      end

      def textcaptcha
        assign_textcaptcha(fetch_q_and_a || config_q_and_a) if perform_textcaptcha? && textcaptcha_config
      end

      private

      def fetch_q_and_a
        return unless should_fetch?

        TextcaptchaApi.new(
          api_key: textcaptcha_config[:api_key],
          api_endpoint: textcaptcha_config[:api_endpoint],
          raise_errors: textcaptcha_config[:raise_errors]
        ).fetch
      end

      def should_fetch?
        textcaptcha_config[:api_key] || textcaptcha_config[:api_endpoint]
      end

      def config_q_and_a
        return unless textcaptcha_config[:questions]

        random_question = textcaptcha_config[:questions][rand(textcaptcha_config[:questions].size)].symbolize_keys!
        answers = (random_question[:answers] || "").split(",").map { |answer| safe_md5(answer) }
        { "q" => random_question[:question], "a" => answers } if random_question && answers.present?
      end

      # check textcaptcha, if incorrect, generate a new textcaptcha
      def validate_textcaptcha
        valid_answers = textcaptcha_cache.read(textcaptcha_key) || []
        reset_textcaptcha
        if valid_answers.include?(safe_md5(textcaptcha_answer))
          # answer was valid, mutate the key again
          self.textcaptcha_key = textcaptcha_random_key
          textcaptcha_cache.write(textcaptcha_key, valid_answers, textcaptcha_cache_options)
          true
        else
          add_textcaptcha_error(too_slow: valid_answers.empty?)
          textcaptcha
          false
        end
      end

      def add_textcaptcha_error(too_slow: false)
        if too_slow
          errors.add(:textcaptcha_answer, :expired, message: "was not submitted quickly enough, try another question instead")
        else
          errors.add(:textcaptcha_answer, :incorrect, message: "is incorrect, try another question instead")
        end
      end

      def reset_textcaptcha
        if textcaptcha_key
          textcaptcha_cache.delete(textcaptcha_key)
          self.textcaptcha_key = nil
        end
      end

      def assign_textcaptcha(q_and_a)
        return unless q_and_a

        self.textcaptcha_question = q_and_a["q"]
        self.textcaptcha_key = textcaptcha_random_key
        textcaptcha_cache.write(textcaptcha_key, q_and_a["a"], textcaptcha_cache_options)
      end

      # strip whitespace pass through mb_chars (a multibyte safe proxy for
      # strings) then downcase
      def safe_md5(answer)
        Digest::MD5.hexdigest(answer.to_s.strip.mb_chars.downcase)
      end

      # a random cache key, time based, random
      def textcaptcha_random_key
        safe_md5(Time.now.to_i + rand(1_000_000))
      end

      def textcaptcha_cache_options
        if textcaptcha_config[:cache_expiry_minutes]
          { expires_in: textcaptcha_config[:cache_expiry_minutes].to_f.minutes }
        else
          {}
        end
      end

      def textcaptcha_cache
        @textcaptcha_cache ||= TextcaptchaCache.new
      end
    end

    private

    # rubocop:disable Security/YAMLLoad
    def build_textcaptcha_config(options)
      if options.is_a?(Hash)
        options
      else
        YAML.safe_load(ERB.new(read_textcaptcha_config).result, aliases: true)[Rails.env]
      end
    rescue StandardError
      raise ArgumentError, "could not find any textcaptcha options, in config/textcaptcha.yml or model - run rake textcaptcha:config to generate a template config file"
    end
    # rubocop:enable Security/YAMLLoad

    def read_textcaptcha_config
      File.read("#{Rails.root || "."}/config/textcaptcha.yml")
    end
  end
end
