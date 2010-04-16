begin
  require 'xml'
  require 'yaml'
  require 'net/http'
  require 'md5'
  require 'logger'  
  require 'bcrypt'
rescue LoadError
end

module ActiveRecord
  module Acts #:nodoc:
    module Textcaptcha #:nodoc:

      def acts_as_textcaptcha(options = nil)
        cattr_accessor :config
        attr_accessor  :spam_answer, :spam_question, :possible_answers
                                
        if options.is_a?(Hash) && options['api_key'] && options['salt']
          self.config = options
        else
          begin
            self.config = YAML.load(File.read("#{(defined? RAILS_ROOT) ? "#{RAILS_ROOT}" : '.'}/config/textcaptcha.yml"))[((defined? RAILS_ENV) ? RAILS_ENV : 'test')]
          rescue Errno::ENOENT
            raise('./config/textcaptcha.yml not found')
          end
        end

        include InstanceMethods
      end
      

      module InstanceMethods

        def skip_spam_check?; false end

        def allowed?; true end

        def validate     
          if new_record?
            if allowed?
              errors.add(:spam_answer, 'is incorrect, try another question instead') unless validate_spam_answer
            else
              errors.add_to_base("Sorry, #{self.class.name.pluralize.downcase} are currently disabled")
            end
          end
        end     
        
        def validate_spam_answer            
          return true  if skip_spam_check?
          return false if !spam_answer || !possible_answers
          possible_answers.include?(encrypt_answer(Digest::MD5.hexdigest(spam_answer.strip.downcase.to_s)))
        end
         
        def encrypt_answers(answers)   
          answers.map {|answer| encrypt_answer(answer) }
        end
           
        def encrypt_answer(answer)          
          return answer unless(config['bcrypt_salt'])
          BCrypt::Engine.hash_secret(answer, config['bcrypt_salt'], (config['bcrypt_cost'] || 10))
        end            
        
        def generate_spam_question(use_textcaptcha = true)
          if use_textcaptcha && config && config['api_key']
            begin
              resp = Net::HTTP.get(URI.parse('http://textcaptcha.com/api/'+config['api_key']))
              if !resp.empty? && xml = XML::Parser.string(resp).parse
                self.spam_question    = xml.find('/captcha/question')[0].inner_xml
                self.possible_answers = encrypt_answers(xml.find('/captcha/answer').map(&:inner_xml))
              end
              return possible_answers if spam_question && !possible_answers.empty?
            rescue SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ECONNREFUSED,
                   Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, URI::InvalidURIError => e
              log_textcaptcha("failed to load or parse textcaptcha with key '#{config['api_key']}'; #{e}")
            end
          end

          # fall back to config questions
          if config && config['questions']
            log_textcaptcha('falling back to random logic question from config')
            random_question       = config['questions'][rand(config['questions'].size)]
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
end
