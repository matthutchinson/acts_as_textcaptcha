require File.expand_path(File.dirname(__FILE__)+'/test_helper')

describe 'Textcaptcha' do

  describe 'validations' do

    before(:each) do
      @note = Note.new
      @note.textcaptcha
    end

    it 'should validate an ActiveRecord object (with multiple correct answers)' do
      @note.spam_question.must_equal('1+1')
      @note.valid?.must_equal false
      @note.errors[:spam_answer].first.must_equal('is incorrect, try another question instead')

      @note.spam_answer = 'two'
      @note.valid?.must_equal true
      @note.errors[:spam_answer].must_be_empty

      @note.spam_answer = '2'
      @note.valid?.must_equal true
      @note.errors[:spam_answer].must_be_empty
    end

    it 'should strip whitespace and downcase spam answer' do
      @note.spam_answer = ' tWo '
      @note.valid?.must_equal true
      @note.errors[:spam_answer].must_be_empty
    end

    it 'should always be valid when record has been saved' do
      @note.spam_answer = '2'
      @note.save!
      @note.textcaptcha

      @note.spam_answer = 'wrong answer'
      @note.new_record?.must_equal false
      @note.valid?.must_equal true
      @note.errors[:spam_answer].must_be_empty
    end

    it 'should always be valid when perform_textcaptcha? is false' do
      @note.turn_off_captcha = true
      @note.valid?.must_equal true
      @note.errors[:spam_answer].must_be_empty

      @note.save.must_equal true
    end

    it 'should validate a non ActiveRecord object' do
      @contact = Contact.new
      @contact.textcaptcha

      @contact.spam_question.must_equal('one+1')
      @contact.spam_answer = 'wrong'
      @contact.valid?.must_equal false

      @contact.spam_answer = 'two'
      @contact.valid?.must_equal true
      @contact.errors[:spam_answer].must_be_empty
    end

    it 'should allow validation to be skipped' do
      @note.valid?.must_equal false
      @note.skip_textcaptcha = true
      @note.valid?.must_equal true
    end

    it 'should protect skip_textcaptcha attribute from mass assignment' do
      @note = Note.new(:skip_textcaptcha => true)
      @note.skip_textcaptcha.must_equal nil
    end
  end

  describe 'with strong parameters' do

    before(:each) do
      @widget = StrongWidget.new
    end

    it 'should work' do
      @widget.spam_answers.must_be_nil
      @widget.textcaptcha
      @widget.spam_question.must_equal('1+1')
      @widget.valid?.must_equal false
      @widget.errors[:spam_answer].first.must_equal('is incorrect, try another question instead')

      @widget.spam_answer = 'two'
      @widget.valid?.must_equal true
      @widget.errors[:spam_answer].must_be_empty
    end
  end

  describe 'textcaptcha API' do

    after(:each) do
      FakeWeb.clean_registry
    end

    it 'should generate spam question from the service' do
      @review = Review.new

      @review.textcaptcha
      @review.spam_question.wont_be_nil
      @review.spam_question.wont_equal('The green hat is what color?')

      @review.spam_answers.wont_be_nil

      @review.valid?.must_equal false
      @review.errors[:spam_answer].first.must_equal('is incorrect, try another question instead')
    end

    it 'should parse a single answer from XML response' do
      @review  = Review.new
      question = 'If tomorrow is Saturday, what day is today?'
      body     = "<captcha><question>#{question}</question><answer>f6f7fec07f372b7bd5eb196bbca0f3f4</answer></captcha>"
      FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :body => body)

      @review.textcaptcha
      @review.spam_question.must_equal(question)
      @review.spam_answers.must_equal(['f6f7fec07f372b7bd5eb196bbca0f3f4'])
      @review.spam_answers.length.must_equal(1)
    end

    it 'should parse multiple answers from XML response' do
      @review  = Review.new
      question = 'If tomorrow is Saturday, what day is today?'
      body     = "<captcha><question>#{question}</question><answer>1</answer><answer>2</answer><answer>3</answer></captcha>"
      FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :body => body)

      @review.textcaptcha
      @review.spam_question.must_equal(question)
      @review.spam_answers.length.must_equal(3)
    end

    describe 'service is unavailable' do

      describe 'should fallback to a user defined question' do

        before(:each) do
          @review = Review.new
        end

        it 'when errors occur' do
          [SocketError, Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Errno::ECONNREFUSED, Errno::ETIMEDOUT,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, URI::InvalidURIError].each do |error|
            FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :exception => error)
            @review.textcaptcha
            @review.spam_question.must_equal('The green hat is what color?')
            @review.spam_answers.wont_be_nil
          end
        end

        it 'when response is OK but body cannot be parsed as XML' do
          FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :body => 'here be gibberish')
          @review.textcaptcha
          @review.spam_question.must_equal('The green hat is what color?')
          @review.spam_answers.wont_be_nil
        end

        it 'when response is OK but empty' do
          FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :body => '')
          @review.textcaptcha
          @review.spam_question.must_equal('The green hat is what color?')
          @review.spam_answers.wont_be_nil
        end
      end
    end

    it 'should not generate any spam question or answer when no user defined questions set' do
      @comment = Comment.new

      FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :exception => SocketError)
      @comment.textcaptcha
      @comment.spam_question.must_equal 'ActsAsTextcaptcha >> no API key (or questions) set and/or the textcaptcha service is currently unavailable (answer ok to bypass)'
      @comment.spam_answers.must_equal 'ok'
    end

    it 'should not generate any spam question or answer when user defined questions set incorrectly' do
      @comment = MovieReview.new

      FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :exception => SocketError)
      @comment.textcaptcha
      @comment.spam_question.must_equal 'ActsAsTextcaptcha >> no API key (or questions) set and/or the textcaptcha service is currently unavailable (answer ok to bypass)'
      @comment.spam_answers.must_equal 'ok'
    end
  end

  describe 'configuration' do

    it 'should be configured with inline hash' do
      Review.textcaptcha_config.must_equal({ :api_key   => '8u5ixtdnq9csc84cok0owswgo',
                                             :questions => [{ :question => 'The green hat is what color?', :answers => 'green' }]})
    end

    it 'should be configured with textcaptcha.yml' do
      Widget.textcaptcha_config[:api_key].must_equal '6eh1co0j12mi2ogcoggkkok4o'
      Widget.textcaptcha_config[:questions].length.must_equal 10
    end
  end
end
