 # sudo gem install libxml-ruby # http://libxml.rubyforge.org
begin
  require 'libxml'
  require 'net/http'
rescue LoadError
end

module ActsAsTextcaptcha

  def acts_as_textcaptcha
    attr_accessor :spam_answer, :spam_question, :possible_answers
    include InstanceMethods
  end

  module InstanceMethods

    def skip_spam_check
      false
    end

    def allowed
      true
    end

    def validate
      if new_record?
        errors.add(:spam_answer, 'is incorrect, try another question instead') unless validate_spam_answer
        unless allowed
          errors.add_to_base("Sorry, #{self.class.name.pluralize.downcase} are currently disabled")
        end
      end
    end

    def errors_on(attribute)
      errors.on(attribute) || []
    end

    def validate_spam_answer
      return true if skip_spam_check
      return false if !spam_answer || !possible_answers
      possible_answers.include?( Digest::MD5.hexdigest(spam_answer.strip.downcase.to_s) )
    end

    def generate_spam_question(use_textcaptcha = true, textcaptcha_key = '8u5ixtdnq9csc84cok0owswgo')
      if use_textcaptcha && textcaptcha_key
        begin
          xml = XML::Parser.string(Net::HTTP.get(URI.parse('http://textcaptcha.com/api/'+textcaptcha_key))).parse
          if xml
            self.spam_question    = xml.find('/captcha/question')[0].inner_xml
            self.possible_answers = xml.find('/captcha/answer').map(&:inner_xml)
          end
          return if spam_question && !possible_answers.empty?
        rescue StandardError => e
          logger.warn "\n>>>> WARNING: Failed to load or parse textcaptcha; #{e}\n\n"
        end
      end

      # fall back to app configured questions
      rand_question         = APP_CONFIG['spam_questions'][rand(APP_CONFIG['spam_questions'].size)]
      self.spam_question    = rand_question['question']
      self.possible_answers = rand_question['answers'].split(',').map! { |ans| Digest::MD5.hexdigest(ans) }
    end
  end
end
