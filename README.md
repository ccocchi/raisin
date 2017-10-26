# Raisin

API versioning via the Accept header.

## Installation

Install as a gem :

```
gem install raisin
```

or add directly to your `Gemfile`

```
gem 'raisin'
```

## Usage

`raisin` allows you to encapsulate your routes within API versions, using a custom `Accept` header to routes them to your controller accordingly.

It uses the fact that Rails router is resolved top to bottom.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  api :v2 do
    resources :users, only: :show
  end

  api :v1, default: true do
    resources :users
    get '/users/sign_in', to: 'sessions#new'
  end
end
```

Clients using the version `v2` will have access to all the methods from the `v1` version plus their `/users/show` routes will be overriden the the new one define in the first `api` block.

## Configuration

```ruby
Raisin.configure do |c|
  c.vendor = 'mycompany' # replace with your vendor
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
