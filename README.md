## ActAsTextcaptcha

[![Gem Version](https://img.shields.io/gem/v/acts_as_textcaptcha.svg?style=flat)](http://rubygems.org/gems/acts_as_textcaptcha)
[![Travis Build Status](https://travis-ci.org/matthutchinson/acts_as_textcaptcha.svg?branch=master)](https://travis-ci.org/matthutchinson/acts_as_textcaptcha)
[![Maintainability](https://api.codeclimate.com/v1/badges/db61b57be5b466b300ab/maintainability)](https://codeclimate.com/github/matthutchinson/acts_as_textcaptcha/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/db61b57be5b466b300ab/test_coverage)](https://codeclimate.com/github/matthutchinson/acts_as_textcaptcha/test_coverage)
[![Depfu](https://badges.depfu.com/badges/34faa769834ba2a324fe18285066991a/overview.svg)](https://depfu.com/github/matthutchinson/acts_as_textcaptcha)

ActsAsTextcaptcha provides spam protection for Rails models using logic
questions from the [TextCaptcha](http://textcaptcha.com/) service (by [Rob
Tuley](https://twitter.com/robtuley). Questions are aimed at a child's age of 7,
so they can be easily solved by humans and proove very difficult for bots.

The gem can be configured to use your own supplied questions instead, or as a
fallback to handle API or network issues.

There are both advantages and disadvantages in using logic questions over image
based captchas, find out more at [textcaptcha.com](http://textcaptcha.com/).

## Requirements

* [Ruby](http://ruby-lang.org/) >= 2.1.0
* [Rails](http://github.com/rails/rails) >= 3
* [Rails.cache](http://guides.rubyonrails.org/caching_with_rails.html#cache-stores)

## Demo

Try a [working demo here](https://acts-as-textcaptcha-demo.herokuapp.com)!

**Or** one-click deploy your own example Rails app to Heroku. See
[here](https://github.com/matthutchinson/acts_as_textcaptcha_demo) for more
details.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://www.heroku.com/deploy?template=https://github.com/matthutchinson/acts_as_textcaptcha_demo/tree/master)

## Installation

Add this line to your Gemfile and run `bundle install`:

```ruby
gem 'acts_as_textcaptcha'
```

Next, for tmodels you would like to protect add:

```ruby
class Comment < ApplicationRecord
  # (this is the simplest way to configure the gem)
  acts_as_textcaptcha :api_key => 'TEXTCAPTCHA_API_IDENTITY'
end
```

Your `TEXTCAPTCHA_API_IDENTITY` should be some reference to yourself (e.g. an
email address, domain or similar where if there are problems with your usage you
can be contacted).

Next, in the controller's `new` action add this:

```ruby
def new
  @comment = Comment.new
  @comment.textcaptcha   # generate and assign question and answer
end
```

Finally add the question and answer fields to your form using the
`textcaptcha_fields` helper. Feel free to arrange the HTML within this block as
you like;

```ruby
<%= textcaptcha_fields(f) do %>
  <div class="field">
    <%= f.label :textcaptcha_answer, @comment.textcaptcha_question %><br/>
    <%= f.text_field :textcaptcha_answer, :value => '' %>
  </div>
<% end %>
```

*NOTE:* If you'd rather NOT use this helper and prefer to write your own form
elements, take a look at the HTML this helper produces
[here](https://github.com/matthutchinson/acts_as_textcaptcha/blob/master/lib/acts_as_textcaptcha/textcaptcha_helper.rb).

*NOTE:* The defaults for [cache
configuration](http://guides.rubyonrails.org/caching_with_rails.html#cache-stores)
changed with Rails 5 and this gem **requires** a working Rails.cache store to
exist.

## Configuration

You can configure captchas with the following options;

* *api_key* (_required_) - reference to yourself (e.g. your email - to identify calls to the textcaptcha.com API).
* *questions* (_optional_) - array of question and answer hashes (see below) A random question from this array will be asked if the web service fails OR if no `api_key` has been set. Multiple answers to the same question are comma separated (e.g. 2,two). Don't use commas in your answers!
* *cache_expiry_minutes* (_optional_) - minutes for answers to persist in the cache (default 10 minutes), see [below for details](https://github.com/matthutchinson/acts_as_textcaptcha#what-does-the-code-do).
* *raise_errors* (_optional_) - if true, errors will be raised if the API endpoint fails to respond correctly (default false).
* *api_endpoint* (_optional_) - set your own JSON API endpoint to fetch questions and answers from (see below).

For example;

    class Comment < ApplicationRecord
      acts_as_textcaptcha :api_key              => 'TEXTCAPTCHA_API_IDENTITY_KEY',
                          :raise_errors         => false,
                          :cache_expiry_minutes => 10,
                          :questions            => [{ 'question' => '1+1', 'answers' => '2,two' },
                                                    { 'question' => 'The green hat is what color?', 'answers' => 'green' }]
    end

### YAML config

The gem can be configured for models individually (as shown above) or with a
config/textcaptcha.yml file. The config file must have an `api_key` defined
and/or an array of questions and answers. Any options defined inline in model
classes take preference over the global configuration in textcaptcha.yml.

The gem comes with a handy rake task to copy over a
[textcaptcha.yml](http://github.com/matthutchinson/acts_as_textcaptcha/raw/master/config/textcaptcha.yml)
template to your config directory;

    rake textcaptcha:config

### Configuring without the TextCaptcha service

To use only your own logic questions, simply omit the `api_key` from the
configuration and define at least one logic question and answer (see above).

You can also set the optional `api_endpoint` config to fetch questions and
answers from your own JSON API URL. This URL must respond with a json object
like this:

    {
      "q": "What number is 4th in the series 39, 11, 31 and nineteen?",
      "a": ["1f0e3dad99908345f7439f8ffabdffc4","1d56cec552bf111de57687e4b5f8c795"]
    }

With `"a"` set to an array of answers as MD5 checksums of the lower-cased
strings. The `api_key` option is ignored if `api_endpoint` is set.

### Toggling TextCaptcha

You can toggle textcaptcha on/off by overriding the `perform_textcaptcha?`
method in your model. If it returns false, no questions will be fetched from the
web service and captcha validation is disabled.

This is useful for writing your own logic to toggle spam protection on or off
e.g. for logged in users. By default the `perform_textcaptcha?` method checks if
the object is a new (unsaved) record.

So by default spam protection is __only__ enabled for creating new records (not
updating). Here is a typical example showing how to overwrite the
`perform_textcaptcha?` method, while maintaining the new record check.

    class Comment < ApplicationRecord
      acts_as_textcaptcha :api_key => 'TEXTCAPTCHA_API_IDENTITY'

      def perform_textcaptcha?
        super && user.admin?
      end
    end

## Translations

The gem uses the standard Rails I18n translation approach (with a fall-back to
English). Unfortunately at present, the TextCaptcha web service only provides
logic questions in English.

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

## Handling Errors

Not all dates, rates or currencies may be available, or the remote endpoint
could be unresponsive. You should consider handling the following errors:

* `ECB::Exchange::DateNotFoundError`
* `ECB::Exchange::CurrencyNotFoundError`
* `ECB::Exchange::ResponseError`
* `ECB::Exchange::ParseError`

Or rescue `ECB::Exchange::Error` to catch any of them.

## Development

Check out this repo and run `bin/setup`, this will install gem dependencies and
generate docs. Use `bundle exec rake` to run tests and generate a coverage
report.

You can also run `bin/console` for an interactive prompt allowing you to
experiment with the code.

## Tests

MiniTest is used for testing. Run the test suite with:

    $ rake test

This gem uses [appraisal](https://github.com/thoughtbot/appraisal) to run tests
with multiple versions of Rails.

* `appraisal rake test` (all tests with all Gemfile variations)
* `appraisal rails-3 rake test` (all tests using a specific gemfile)

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
[Travis](https://travis-ci.org/matthutchinson/acts_as_textcaptcha). Read the
[contributing
guidelines](https://github.com/matthutchinson/acts_as_textcaptcha/blob/master/CONTRIBUTING.md)
for more details.

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct. See
[here](https://github.com/matthutchinson/acts_as_textcaptcha/blob/master/CODE_OF_CONDUCT.md)
for more details.

## Todo

* Allow translatable user configured questions and answers
* Allow `Net::HTTP` to be swapped out for any another HTTP client.

## License

The code is available as open source under the terms of
[LGPL-3](https://opensource.org/licenses/LGPL-3.0).

## Who's who?

* [ActsAsTextcaptcha](http://github.com/matthutchinson/acts_as_textcaptcha) and [little robot drawing](http://www.flickr.com/photos/hiddenloop/4541195635/) by [Matthew Hutchinson](http://matthewhutchinson.net)
* [TextCaptcha](http://textcaptcha.com) API and service by [Rob Tuley](https://twitter.com/robtuley)

## Links

* [Demo](https://acts-as-textcaptcha-demo.herokuapp.com)
* [Travis CI](http://travis-ci.org/#!/matthutchinson/acts_as_textcaptcha)
* [Maintainability](https://codeclimate.com/github/matthutchinson/acts_as_textcaptcha/maintainability)
* [Test Coverage](https://codeclimate.com/github/matthutchinson/acts_as_textcaptcha/test_coverage)
* [RDoc](http://rdoc.info/projects/matthutchinson/acts_as_textcaptcha)
* [Wiki](http://wiki.github.com/matthutchinson/acts_as_textcaptcha/)
* [Issues](http://github.com/matthutchinson/acts_as_textcaptcha/issues)
* [Report a bug](http://github.com/matthutchinson/acts_as_textcaptcha/issues/new)
* [Gem](http://rubygems.org/gems/acts_as_textcaptcha)
* [GitHub](http://github.com/matthutchinson/acts_as_textcaptcha)
