begin
  require 'xml'
  require 'yaml'
  require 'net/http'
  require 'md5'
  require 'logger'
rescue LoadError
end

module ActsAsTextcaptcha

  def acts_as_textcaptcha(api_key)
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

    def textcaptcha_config
      if defined? RAILS_ROOT
        YAML.load(File.read(RAILS_ROOT + '/config/textcaptcha.yml'))[RAILS_ENV]
      else
        YAML.load(File.read('./textcaptcha.yml'))['development']
      end
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
      return true  if skip_spam_check
      return false if !spam_answer || !possible_answers
      possible_answers.include?( Digest::MD5.hexdigest(spam_answer.strip.downcase.to_s) )
    end

    def generate_spam_question(use_textcaptcha = true)
      config = textcaptcha_config
      if use_textcaptcha && config['api_key']
        begin
          resp = Net::HTTP.get(URI.parse('http://textcaptcha.com/api/'+config['api_key']))
          xml  = XML::Parser.string(resp).parse
          if xml
            self.spam_question    = xml.find('/captcha/question')[0].inner_xml
            self.possible_answers = xml.find('/captcha/answer').map(&:inner_xml)
          end
          return if spam_question && !possible_answers.empty?
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ECONNREFUSED,
               Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
          log("Failed to load textcaptcha with key #{config['api_key']}; #{e}")
        end
      end

      # fall back to app configured questions
      if config['spam_questions']
        log('Falling back to random question from config')
        random_question       = config['spam_questions'][rand(config['spam_questions'].size)]
        self.spam_question    = rand_question['question']
        self.possible_answers = rand_question['answers'].split(',').map!{|ans| Digest::MD5.hexdigest(ans)}
      end
      possible_answers
    end

    private
    def log(message)
      logger ||= Logger.new(STDOUT)
      logger.info "Textcaptcha >> #{message}"
    end
  end
end
