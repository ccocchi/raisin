# Raisin

Elegant, modular and performant APIs in Rails

## Installation

Add this line to your application's Gemfile:

    gem 'raisin'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install raisin

## Usage

Raisin is composed of two main elements : a router and a lists of API. An API is a file containing your endpoints,
with their paths, implementation and documentation. The router is where you modelize your API, saying which
API goes to which version.

Under the hood, raisin will generate classes (one for each enpoint), enabling us to use unit test for them, but keeping it transparent for Rails router.

Here's a basic example of an API

```ruby
class UsersAPI < Raisin::API
  get '/users' do
    expose(:user) { User.all }
  end

  post do
    expose(:user) { User.new(params[:user]) }

    response do
      user.save
      respond_with(user)
    end
  end
end
```

### Endpoints

Each endoint is defined by the http verb used to access it, its path and its implementation. When the path is omitted, raisin will default it to '/'. And since we are in the UsersAPI, raisin will set a prefix to 'users'. So the `post do` is equivalent to `post '/users' do`.
Same for the get method, since its path is the same as the prefix, it can be omitted.

The `expose` method allows you to create variables elegantly and to access it in your endpoints body or your views (in you gems like jbuilder or rabl-rails). These exposed variables are evaluated in the response block so you have access to everything (like the params object).

The response block is where your endpoint logic goes. It can be optionnal, as you can see in the get method. If no response is specified, raisin will behave like a a standart rails controller method (thus trying to render a file with tht same name as the endpoint or fallback to API rendering)

We talk about the name of the endpoint but how is it determine? raisin is smart enough to recognize basic CRUD operations and RESTful endpoint

```ruby
class UsersAPI < Raisin::API
  get '/users' {}       # index
  post '/users' {}      # create

  put '/users/:id/foo'  # foo
end
```

You can see theses names if you run `rake routes` in your console. If you prefer to name your endpoint yourself, you can do it by passing an `:as` option

```ruby
get '/users', as: :my_method_name
```

### Namespaces

You often have endpoint that have a portion of their path in commons, a namespace in raisin. The most used is RESTful applications is the "member" namespace, that look like `/resource_name/:id`.

raisin provides both generic namespace and member out of the box

```ruby
class UsersAPI < Raisin::API
  namespace 'foo' do
    get '/bar' {}   # GET /foo/bar
  end

  member do
    put do          # PUT /users/:id
      response do
        user.update_attributes(params[:user])
        respond_with(user)
      end
    end
  end
end
```

You see that in the `update` method we used a user variable. This is because you can also expose variable for a whole namespace, which does member automatically (the variable name will be the resource name singularize, 'user' in our example)

Namespaces can be nested.

### Miscellanous

You can add `single_resource` in your API for single resources.

Resources can be nested just as regular Rails. For example

```ruby
class CommentsAPI < Raisin::API
  nested_into_resource :posts

  get '/comments/:id' do  # GET /posts/:post_id/comments/:id
    expose(:comment) { post.comments.find(params[:id]) }
  end
end
```

### Router

raisin router is similar to the `routes.rb` in Rails. APIs that appears at the top have precedence on the ones after. Versionning is done by encapsulating APIs inside `version` block. `:all` can be used is a part of your api is accessible for all versions.

```ruby
# /app/api/my_api.rb
class MyApi < Raisin::Router
  version :v2, using: :header, vendor: 'mycompany' do
    mount CommentsApi
  end

  version [:v2, :v1] do
    mount PostsApi
    mount UsersApi
  end

  version :all do
    mount LoginApi
  end
end

# /config/routes.rb

mount_api MyApi
```

Versionning can be done via the HTTP Accept header (application/vnd.mycompany-v1+json for example) or via the URL
(/v1/users/). When using the header versionning, the vendor must be set. These options can be set globally when configuring raisin.

## Configuration

```ruby
Raisin.configure do |c|
  c.version.using =   :header
  c.version.vendor =  'mycompany'
end
```

If you are using versionning via header, you also need to add a middleware to your application stack

```ruby
#config/application.rb

config.middleware.use Raisin::Middleware
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
