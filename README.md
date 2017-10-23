# EdgeAuth (Akamai Authorization Token)

this gem is authorization token generator for Akamai, you can configure your property at [https://control.akamai.com]
inspired by [Akamai-AuthToken-Ruby](https://github.com/AstinCHOI/Akamai-AuthToken-Ruby)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'edge_auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install edge_auth

## Usage

### Basic Usage

```Ruby
edge_auth = Akamai::EdgeAuth.new(key: "yourkeyhere")
token = edge_auth.generate_token(start_time: "now", window_seconds: 30, acl: "/path/whatever")
```

Your token should look like this by very default options :

```
hdnts=st=1508777863~exp=1508777893~acl=/path/whatever~hmac=fded4c1133a50942a36cc16a9a94d68e8573d10d144d03860a7c3a3734d13dff
```

### Initialize

| Parameter | Description |
|-----------|-------------|
| token_type| Token type cookies or URL. [ Default: URL] |
| token_name | Parameter name for the new token. [ Default: hdnts ] |
| key | Secret required to generate the token. It must be hexadecimal digit string with even-length. |
| algorithm  | Algorithm to use to generate the token. (sha1, sha256, or md5) [ Default:sha256 ] |
| field_delimiter | Character used to delimit token body fields. [ Default: ~ ] |
| acl_delimiter | Character used to delimit acl. [ Default: ! ] |

### Generate Token

| Parameter | Description |
|-----------|-------------|
| start_time | What is the start time? (Use string 'now' for the current time) |
| end_time | When does this token expire? 'end_time'  |
| window_seconds | How long is this token valid for? overrides 'end_time' |
| acl | Generate token for Access Control List [ Example: "/live/*" it will allow all stream under /live/ path ] |
| url | Generate token for url |
| escape_early | Causes strings to be 'url' encoded before being used. |
| ip | IP Address to restrict this token to. (Troublesome in many cases (roaming, NAT, etc) so not often used) |
| payload | Additional text added to the calculated digest. |
| session_id | The session identifier for single use tokens or other advanced cases. |
| salt | Additional data validated by the token but NOT included in the token body. (It will be deprecated) |


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/sukorenomw/akamai-edgeauth/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

Bug reports and pull requests are welcome on GitHub at https://github.com/sukorenomw/akamai-edgeauth. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

Copyright 2017 Akamai Technologies http://developer.akamai.com.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
