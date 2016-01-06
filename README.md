# UpdateRequest

Rails engine to provide approvable resource update requests

## Installation

Add this line to your application's Gemfile:

    gem 'update_request'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install update_request
    
Copy the migrations to your Rails application

    rake update_request:install:migrations
        
Run the migrations

    rake db:migrate
    
## Usage

### Creating an update request

```ruby
# User authentication and authorization code

UserRequest::Request.new(
  requester: user,
  updateable: customer, 
  update_schema: { 
    id: 1, 
    name: "New name", 
    orders_attributes: [
      {
        id: 3,
        deliver_notes: "Revised deliver notes"
      }
    ]
  }
)
```

### Applying an update

```ruby
# Admin user authentication and authorization code

update_request.apply(admin_user)
```

### Retrieve a resource's update requests

```ruby
class Customer < ActiveRecord::Base
  has_many :update_requests, as: :updateable, class_name: 'UpdateRequest::Request'
end


customer.update_requests
```


