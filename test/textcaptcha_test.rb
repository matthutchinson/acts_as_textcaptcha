require File.expand_path(File.dirname(__FILE__)+'/test_helper')

describe 'Textcaptcha' do

  describe 'validations' do

    before(:each) do
      @note = Note.new
      @note.textcaptcha
    end

    it 'should validate an ActiveRecord object (with multiple correct answers)' do
      @note.textcaptcha_question.must_equal('1+1')
      @note.valid?.must_equal false
      @note.errors[:textcaptcha_answer].first.must_equal('is incorrect, try another question instead')

      @note.textcaptcha_answer = 'two'
      @note.valid?.must_equal true
      @note.errors[:textcaptcha_answer].must_be_empty

      @note.textcaptcha_answer = '2'
      @note.valid?.must_equal true
      @note.errors[:textcaptcha_answer].must_be_empty
    end

    it 'should strip whitespace and downcase answer' do
      @note.textcaptcha_answer = ' tWo '
      @note.valid?.must_equal true
      @note.errors[:textcaptcha_answer].must_be_empty
    end

    it 'should always be valid when record has been saved' do
      @note.textcaptcha_answer = '2'
      @note.save!
      @note.textcaptcha

      @note.textcaptcha_answer = 'wrong answer'
      @note.new_record?.must_equal false
      @note.valid?.must_equal true
      @note.errors[:textcaptcha_answer].must_be_empty
    end

    it 'should always be valid when perform_textcaptcha? is false' do
      @note.turn_off_captcha = true
      @note.valid?.must_equal true
      @note.errors[:textcaptcha_answer].must_be_empty

      @note.save.must_equal true
    end

    it 'should validate a non ActiveRecord object' do
      @contact = Contact.new
      @contact.textcaptcha

      @contact.textcaptcha_question.must_equal('one+1')
      @contact.textcaptcha_answer = 'wrong'
      @contact.valid?.must_equal false

      @contact.textcaptcha_answer = 'two'
      @contact.valid?.must_equal true
      @contact.errors[:textcaptcha_answer].must_be_empty
    end
  end

  describe 'with fast expiry time' do

    before(:each) do
      @comment = FastComment.new
    end

    it 'should work' do
      @comment.textcaptcha
      @comment.textcaptcha_question.must_equal('1+1')
      @comment.textcaptcha_answer = 'two'
      sleep(0.01)

      @comment.valid?.must_equal false
      @comment.errors[:textcaptcha_answer].first.must_equal('was not submitted quickly enough, try another question instead')
    end
  end

  describe 'textcaptcha API' do

    after(:each) do
      FakeWeb.clean_registry
    end

    it 'should generate a question from the service' do
      @review = Review.new

      @review.textcaptcha
      @review.textcaptcha_question.wont_be_nil
      @review.textcaptcha_question.wont_equal('The green hat is what color?')

      find_in_cache(@review.textcaptcha_key).wont_be_nil

      @review.valid?.must_equal false
      @review.errors[:textcaptcha_answer].first.must_equal('is incorrect, try another question instead')
    end

    it 'should parse a single answer from XML response' do
      @review  = Review.new
      question = 'If tomorrow is Saturday, what day is today?'
      body     = "<captcha><question>#{question}</question><answer>f6f7fec07f372b7bd5eb196bbca0f3f4</answer></captcha>"
      FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :body => body)

      @review.textcaptcha
      @review.textcaptcha_question.must_equal(question)
      find_in_cache(@review.textcaptcha_key).must_equal(['f6f7fec07f372b7bd5eb196bbca0f3f4'])
    end

    it 'should parse multiple answers from XML response' do
      @review  = Review.new
      question = 'If tomorrow is Saturday, what day is today?'
      body     = "<captcha><question>#{question}</question><answer>1</answer><answer>2</answer><answer>3</answer></captcha>"
      FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :body => body)

      @review.textcaptcha
      @review.textcaptcha_question.must_equal(question)
      find_in_cache(@review.textcaptcha_key).length.must_equal(3)
    end

    it 'should fallback to a user defined question when api returns nil' do
      @review = Review.new
      FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :body => '')
      @review.textcaptcha
      @review.textcaptcha_question.must_equal('The green hat is what color?')
      find_in_cache(@review.textcaptcha_key).wont_be_nil
    end

    it 'should not generate any question or answer when no user defined questions set' do
      @comment = Comment.new

      FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :exception => SocketError)
      @comment.textcaptcha
      @comment.textcaptcha_question.must_equal nil
      @comment.textcaptcha_key.must_equal nil
    end

    it 'should not generate any question or answer when user defined questions set incorrectly' do
      @comment = MovieReview.new

      FakeWeb.register_uri(:get, %r|http://textcaptcha\.com/api/|, :exception => SocketError)
      @comment.textcaptcha
      @comment.textcaptcha_question.must_equal nil
      @comment.textcaptcha_key.must_equal nil
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

  describe 'with strong parameters' do

    it 'should work with accessible_attr widget ' do
      @widget = StrongAccessibleWidget.new

      @widget.textcaptcha
      @widget.textcaptcha_question.must_equal('1+1')
      @widget.valid?.must_equal false
    end

    it 'should work with protected_attr widget ' do
      @widget = StrongProtectedWidget.new

      @widget.textcaptcha
      @widget.textcaptcha_question.must_equal('1+1')
      @widget.valid?.must_equal false
    end
  end

  describe 'when missing config' do

    it 'should raise an error' do
      YAML.stub :load, -> { raise 'some bad things happened' } do

        error = assert_raises(ArgumentError) do
          class NoConfig
            include ActiveModel::Validations
            include ActiveModel::Conversion
            extend ActsAsTextcaptcha::Textcaptcha
            acts_as_textcaptcha
          end
        end

        error.message.must_match /could not find any textcaptcha options/
      end
    end
  end
end
