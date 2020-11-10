# frozen_string_literal: true

module ActsAsTextcaptcha
  class TextcaptchaConfig
    YAML = <<~CONFIG
      development: &common_settings
        api_key: 'TEXTCAPTCHA_API_IDENT' # see http://textcaptcha.com for details
        # api_endpoint: nil        # Optional API URL to fetch questions and answers from
        # raise_errors: false      # Optional flag, if true errors will be raised if the API endpoint fails
        # cache_expiry_minutes: 10 # Optional minutes for captcha answers to persist in the cache (default 10 minutes)

        questions:
            - question: 'Is ice hot or cold?'
              answers: 'cold'
            - question: 'what color is an orange?'
              answers: 'orange'
            - question: 'what is two plus 3?'
              answers: '5,five'
            - question: 'what is 5 times two?'
              answers: '10,ten'
            - question: 'How many colors in the list, green, brown, foot and blue?'
              answers: '3,three'
            - question: 'what is Georges name?'
              answers: 'george'
            - question: '11 minus 1?'
              answers: '10,ten'
            - question: 'is boiling water hot or cold?'
              answers: 'hot'
            - question: 'what color is my blue shirt today?'
              answers: 'blue'
            - question: 'what is 16 plus 4?'
              answers: '20,twenty'

      test:
        <<: *common_settings
        api_key: 'TEST_TEXTCAPTCHA_API_IDENT'

      production:
        <<: *common_settings
    CONFIG

    def self.create(path: "./config/textcaptcha.yml")
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, "w") { |f| f.write(YAML) }
    end
  end
end
