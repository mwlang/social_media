# SocialMedia

    Facebook: 1,712,000,000 users
    WhatsApp 1,000,000,000 users
    Facebook Messenger: 1,000,000,000 users
    QQ: 899,000,000 users
    WeChat: 806,000,000 users
    QZone: 652,000,000 users
    Tumblr: 555,000,000 users
    Instagram: 500,000,000 users
    Twitter: 313,000,000 users
    Baidu Tieba: 300,000,000 users
    Skype: 300,000,000 users
    Sina Weibo: 282,000,000 users
    Viber: 249,000,000 users
    Line: 218,000,000 users
    Snapchat: 200,000,000 users

## Usage
The idea is to treat social media sites like databases.  With that in mind, we'll have adapters for each each social media service
that we connect, passing the appropriate connection strings to.  Once connected, we can then query and publish to the connection using
the same method calls and parameters across the various social media services.  Of course some services will have more functionality
than others.  The library can be configured to silently ignore limited functionality or to explicitly raise errors.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'social_media'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install social_media
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
