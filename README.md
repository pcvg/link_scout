# LinkScout

Welcome to LinkScout gem!

LinkScout helps users to find broken links by analysing response code or body.

It can take single or multiple URLs as input making it easy to handle link checking in larger batches.
It can also follow links through redirect chains making sure links eventually work for your users.

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
  ```ruby
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
  ```ruby
  LinkScout::run(url, options)
  ```

  ```ruby
  LinkScout::run(url: url, option: value)
  ```

  ### Multiple with shared options
  ```ruby
  LinkScout::run([url, url1, url2], options)
  ```

  ### Multiple with individual options
  ```ruby
  LinkScout::run([{ url: url }, { url: url1, option: value }])
  ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pcvg/link_scout. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LinkScout project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pcvg/link_scout/blob/master/CODE_OF_CONDUCT.md).
