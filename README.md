# LinkScout

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/link_scout`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'link_scout'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install link_scout

## Usage
```
options = {
  success: 200,
  follow: true,
  limit: 1,
  target: 'http://target.com',
  deeplink_param: 'deeplink',
  pattern: /abc/i,
  antipattern: /cde/i,
}
```
### Single URLS
`LinkScout::run(url, options)`

`LinkScout::run(url: url, option: value)`

### Multiple with shared options
`LinkScout::run([url, url1, url2], options)`

### Multiple with individual options
`LinkScout::run([{ url: url }, { url: url1, option: value }])

## Options

Expects options with the following keys:
- url | URL - The URL to be checked ( only needed when multiple URLS with different options should be checked)
- success | String, Array - (Default: 200) - Array of HTTP Status Codes that are considered as successfull, eg. 200,202
- follow | Boolean (Default: true) - Follow all redirects and return checks only if the last response is successfull or not
- limit | Integer (Default: 10) - Max. number of redirects to follow
- target | URL - If provided check if the final response ended at the target url
- deeplink_param | String - a param in the url that is considered to be the deeplink, if deeplink_param is found deeplink option is set automatically
- pattern | Regex - Return "success" if a given pattern can be found on the response.body, e.g. /^my-pattern/ig
- antipattern | Regex - Return "fail" if a given pattern can be found on the response.body, e.g. /^my-anti-pattern/ig

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/link_scout. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LinkScout project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/link_scout/blob/master/CODE_OF_CONDUCT.md).
