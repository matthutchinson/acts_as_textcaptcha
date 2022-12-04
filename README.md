## ActAsTextcaptcha

[![Gem](https://img.shields.io/gem/v/acts_as_textcaptcha.svg?style=flat)](http://rubygems.org/gems/acts_as_textcaptcha)
[![Travis](https://img.shields.io/travis/com/matthutchinson/acts_as_textcaptcha/master.svg?style=flat)](https://travis-ci.com/matthutchinson/acts_as_textcaptcha)
[![Depfu](https://img.shields.io/depfu/matthutchinson/acts_as_textcaptcha.svg?style=flat)](https://depfu.com/github/matthutchinson/acts_as_textcaptcha)
[![Maintainability](https://api.codeclimate.com/v1/badges/c67969dd7b921477bdcc/maintainability)](https://codeclimate.com/github/matthutchinson/acts_as_textcaptcha/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/c67969dd7b921477bdcc/test_coverage)](https://codeclimate.com/github/matthutchinson/acts_as_textcaptcha/test_coverage)

ActsAsTextcaptcha provides spam protection for Rails models with text-based
logic question captchas. Questions are fetched from [Rob
Tuley's](https://twitter.com/robtuley)
[textcaptcha.com](https://textcaptcha.com/). They can be solved easily by humans
but are tough for robots to crack.

The gem can also be configured with your own questions; as an alternative, or as
a fallback to handle any API issues. For reasons on why logic based captchas
are a good idea visit [textcaptcha.com](https://textcaptcha.com).

## Requirements

* [Ruby](http://ruby-lang.org/) >= 2.5
* [Rails](http://github.com/rails/rails) >= 4
* A valid [Rails.cache](http://guides.rubyonrails.org/caching_with_rails.html#cache-stores) (not `:null_store`)

## Demo

Try a [working demo here](https://acts-as-textcaptcha.hiddenloop.dev)!

## Installation

Add this line to your Gemfile and run `bundle install`:

```ruby
gem 'acts_as_textcaptcha'
```

Add this to models you'd like to protect:

```ruby
class Comment < ApplicationRecord
  acts_as_textcaptcha api_key: 'TEXTCAPTCHA_API_IDENTITY'
  # see below for more config options
end
```

[Rob](https://twitter.com/robtuley) requests that your
`TEXTCAPTCHA_API_IDENTITY` be some reference to yourself (e.g. an email address,
domain or similar) so you can be contacted should any usage problem occur.

In your controller's `new` action call the `textcaptcha` method:

```ruby
def new
  @comment = Comment.new
  @comment.textcaptcha   
end
```

Make sure these textcaptcha params
(`:textcaptcha_answer, :textcaptcha_key`) are permitted in your create (or update) action:

```ruby
def create
  @comment = Comment.create(commment_params)
  # ... etc
end

private

def commment_params
  params.require(:comment).permit(:textcaptcha_answer, :textcaptcha_key, :name, :comment_text)
end
```

**NOTE**: if the captcha is submitted incorrectly, a new captcha will be
automatically generated on the `@comment` object.

Next, add the question and answer fields to your form using the
`textcaptcha_fields` helper. Arrange the HTML within this block as you like.

```ruby
<%= textcaptcha_fields(f) do %>
  <div class="field">
    <%= f.label :textcaptcha_answer, @comment.textcaptcha_question %><br/>
    <%= f.text_field :textcaptcha_answer, :value => '' %>
  </div>
<% end %>
```

If you'd prefer to construct your own form elements, take a look at the HTML
produced
[here](https://github.com/matthutchinson/acts_as_textcaptcha/blob/master/lib/acts_as_textcaptcha/textcaptcha_helper.rb).

Finally set a valid [cache
store](https://guides.rubyonrails.org/caching_with_rails.html#cache-stores) (not `:null_store`) for your environments:

```ruby
# e.g. in config/environments/*.rb
config.cache_store = :memory_store
```

You can run `rails dev:cache` on to enable a memory store cache in the development environment.

## Configuration

The following options are available (only `api_key` is required):

* **api_key** (_required_) - a reference to yourself (e.g. your email or domain).
* **questions** (_optional_) - array of your own questions and answers (see below).
* **cache_expiry_minutes** (_optional_) - how long valid answers are cached for (default 10 minutes).
* **raise_errors** (_optional_) - if true, API or network errors are raised (default false, errors logged).
* **api_endpoint** (_optional_) - set your own JSON API endpoint to fetch from (see below).

For example:

```ruby
class Comment < ApplicationRecord
  acts_as_textcaptcha api_key: 'TEXTCAPTCHA_API_IDENTITY_KEY',
                      raise_errors: false,
                      cache_expiry_minutes: 10,
                      questions: [
                        { 'question' => '1+1', 'answers' => '2,two' },
                        { 'question' => 'The green hat is what color?', 'answers' => 'green' }
                      ]
end
```

### YAML config

You can apply an app wide config with a `config/textcaptcha.yml` file. Use this
rake task to add one from a
[template](https://github.com/matthutchinson/acts_as_textcaptcha/blob/master/lib/acts_as_textcaptcha/textcaptcha_config.rb):

    $ bundle exec rake textcaptcha:config

**NOTE**: Any options set in models take preference over this config.

### Config without the TextCaptcha service

To use __only__ your own logic questions, omit the `api_key` and set them in the
config (see above). Multiple answers to the same question must be comma
separated e.g. `2,two` (so do not include commas in answers).

You can optionally set your own `api_endpoint` to fetch questions and answers
from. The URL must respond with a JSON object like this:

```ruby
{
  "q": "What number is 4th in the series 39, 11, 31 and nineteen?",
  "a": ["1f0e3dad99908345f7439f8ffabdffc4","1d56cec552bf111de57687e4b5f8c795"]
}
```

With `"a"` being an array of answer strings, MD5'd, and lower-cased. The
`api_key` option is ignored if an `api_endpoint` is set.

### Toggling TextCaptcha

Enable or disable captchas by overriding the `perform_textcaptcha?` method (in
models). By default the method checks if the object is a new (unsaved) record.
So spam protection is __only__ enabled for creating new records (not updating).

Here's an example overriding the default behaviour but maintaining the new
record check.

```ruby
class Comment < ApplicationRecord
  acts_as_textcaptcha :api_key => 'TEXTCAPTCHA_API_IDENTITY'

  def perform_textcaptcha?
    super && user.admin?
  end
end
```

## Translations

The following strings are translatable (with Rails I18n translations):

```yaml
en:
  activerecord:
    errors:
      models:
        comment:
          attributes:
            textcaptcha_answer:
              incorrect: "is incorrect, try another question instead"
              expired: "was not submitted quickly enough, try another question instead"
  activemodel:
    attributes:
      comment:
        textcaptcha_answer: "TextCaptcha answer"
```

**NOTE**: The textcaptcha.com API only provides logic questions in English.

## Handling Errors

The API may be unresponsive or return an unexpected response. If you've set
`raise_errors: true`, consider handling these errors:

* `ActsAsTextcaptcha::ResponseError`
* `ActsAsTextcaptcha::ParseError`
* `ActsAsTextcaptcha::ApiKeyError`

## Development

Check out this repo and run `bin/setup`, this will install gem dependencies and
generate docs. Use `bundle exec rake` to run tests and generate a coverage
report.

You can also run `bin/console` for an interactive prompt to experiment with the
code.

## Tests

MiniTest is used for testing. Run the test suite with:

    $ rake test

This gem uses [appraisal](https://github.com/thoughtbot/appraisal) to test
against multiple versions of Rails.

* `appraisal rake test` (run tests against all Gemfile variations)
* `appraisal rails-3 rake test` (run tests against a specific Gemfile)

## Docs

Generate docs for this gem with:

    $ rake rdoc

## Troubles?

If you think something is broken or missing, please raise a new
[issue](https://github.com/matthutchinson/acts_as_textcaptcha/issues). Please
remember to check it hasn't already been raised.

## Contributing

Bug [reports](https://github.com/matthutchinson/acts_as_textcaptcha/issues) and
[pull requests](https://github.com/matthutchinson/acts_as_textcaptcha/pulls) are
welcome on GitHub. When submitting pull requests, remember to add tests covering
any new behaviour, and ensure all tests are passing on
[Travis](https://travis-ci.com/matthutchinson/acts_as_textcaptcha). Read the
[contributing
guidelines](https://github.com/matthutchinson/acts_as_textcaptcha/blob/master/CONTRIBUTING.md)
for more details.

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct. See
[here](https://github.com/matthutchinson/acts_as_textcaptcha/blob/master/CODE_OF_CONDUCT.md)
for more details.

## Todo

* Allow translatable user supplied questions and answers in config
* Allow `Net::HTTP` to be swapped out for any another HTTP client.

## License

The code is available as open source under the terms of
[LGPL-3](https://opensource.org/licenses/LGPL-3.0).

## Who's who?

* [ActsAsTextcaptcha](http://github.com/matthutchinson/acts_as_textcaptcha) and [little robot drawing](http://www.flickr.com/photos/hiddenloop/4541195635/) by [Matthew Hutchinson](http://matthewhutchinson.net)
* [TextCaptcha](https://textcaptcha.com) API and service by [Rob Tuley](https://twitter.com/robtuley)

## Links

* [Demo](https://acts-as-textcaptcha.hiddenloop.dev)
* [Travis CI](http://travis-ci.com/matthutchinson/acts_as_textcaptcha)
* [Maintainability](https://codeclimate.com/github/matthutchinson/acts_as_textcaptcha/maintainability)
* [Test Coverage](https://codeclimate.com/github/matthutchinson/acts_as_textcaptcha/test_coverage)
* [RDoc](http://rdoc.info/projects/matthutchinson/acts_as_textcaptcha)
* [Wiki](http://wiki.github.com/matthutchinson/acts_as_textcaptcha/)
* [Issues](http://github.com/matthutchinson/acts_as_textcaptcha/issues)
* [Report a bug](http://github.com/matthutchinson/acts_as_textcaptcha/issues/new)
* [Gem](http://rubygems.org/gems/acts_as_textcaptcha)
* [GitHub](http://github.com/matthutchinson/acts_as_textcaptcha)
