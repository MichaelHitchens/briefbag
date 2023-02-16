# Briefbag

[![Gem Version](https://badge.fury.io/rb/briefbag.svg)](https://badge.fury.io/rb/dadatas)
[![Gem](https://img.shields.io/gem/dt/briefbag.svg)](https://rubygems.org/gems/briefbag)


## Application config management library.

### What's Briefbag for?

Briefbag allows any ruby application to assemble configs `.yml` files, into single `.yml` file for the `development` environment 
or use interact with [Consul's](http://www.consul.io/) distributed key value store

### Does it work in rails?
Yup! In fact, we're using it in all of our rails production apps instead

### How it is work
#### Overview
It works quite easily,
you are a developer and work in the `development` environment, it is more convenient for you to use one `.yml` file with configuration. 
No more `.yml` zoos, or ENV variables -  all in one place.
You just create constant (for example usage) in your application `APPLICATION_CONFIG` and forward.
refer to the desired config as an object. To do this, under the hood, I use [Struct](https://ruby-doc.org/core-2.7.5/Struct.html)
therefore, the appeal becomes simpler: `APPLICATION_CONFIG.database.port`

And what if you need to share the configuration file with colleagues, or use this design at other stands - `production` environment. 
Consul comes to the rescue. Thanks to him, you can act config and undress in different stands.
Generation `.yml` file there are 2 rake tasks: rake

- **rake settings:consul2yml** -  Get key/value variables from consul to `.yml` file
- **rake settings:template2yml** - Generate basic `.yml` for your app. Based on it, you can fill it with any values


Need add to you Rakefile
```ruby

require 'briefbag'

spec = Gem::Specification.find_by_name 'briefbag'
load "#{spec.gem_dir}/lib/tasks/settings.rake"
```

#### Notifications:
If you use `.yml` .You will see: 
> NOTICE! Your app using configs from yml file

If you use Consul. You will see: 

> NOTICE! Your app using configs from consul now
If you want to use local configs need to create config file. Just run `rake settings:consul2yml`


If you don't have access to consul (for example VPN or bad connections)
You will see:
>ALARM! You try are get consul config, but not connection to consul.
Please! connect to VPN or check consul configuration

## Installation
Adding to your project:

```ruby
gem 'briefbag'
```
Then run `bundle install`

or 

Or install it yourself as:
`gem install briefbag`

# Usage
> params to input:
- **consul_host(string)** -  *(required)* Consul service ip or host.
- **consul_port(integer)** - *(optional)* Default value ${443}. Consul service port.
- **consul_token(string)** - *(optional)* If you use ACL Token.
- **consul_folder(string)** *(required)* Name config folder in consul.
- **environment(string)** - *(optional)* Default value ${development}. Environment in consul.
- **config_name(string)** - *(optional)* Default value ${application}. Config name in your application for example path to yml file:  'config/application.yml' you need use name 'application'.

```ruby
require 'briefbag'

params_config = {
  consul_host: 'consul.example.com',
  consul_port: 8500,
  consul_token: '233b604b-b92e-48c8-a253-5f11514e4b50',
  consul_folder: 'briefbag',
  environment: 'test', 
  config_name: 'some_config' 
}
configs = Briefbag::Configuration.new(params_config).call
=> #<struct database=#<struct adapter="postgresql", host="localhost", port=5432, database="tets_dev", username="postgres", password=""... 
> configs.database
=> #<struct adapter="postgresql", host="localhost", port=5432, database="tets_dev", username="postgres", password=""... 
> configs.database.username
=> "postgres"

```
example yml file: 

```yml
---
development:
  database:
    adapter: postgresql
    host: localhost
    port: 5432
    database: tets_dev
    username: postgres
    password: ''
    schema_search_path: public
    encoding: utf8
    pool: 30
  puma:
    port: 3000
    workers: 0
    min_threads: 1
    max_threads: 4
    max_ram: 4048
    restart_frequency: 21600
  sidekiq:
    login: admin
    password: admin
    queues:
      default: 2
    concurrency: 2
```

## Contributions

Bug reports and pull requests are welcome on GitHub at https://github.com/MichaelHitchens/briefbag.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
