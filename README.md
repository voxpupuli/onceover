# Controlrepo Gem

## Configuration

You can modify the regexes that the gem uses to filter classes that it finds into roles and profiles. Just set up a Controlrepo object and pass regexes to the below settings. 

```ruby
repo = Controlrepo.new()
repo.role_regex = /.*/ # Tells the class how to find roles, will be applied to repo.classes
repo.profile_regex = /.*/ # Tells the class how to find profiles, will be applied to repo.classes
```

Note that you will need to call the `roles` and `profiles` methods on the object you just instantiated, not the main class e.g. `repo.roles` not `Controlrepo.roles`

# Running the tests

This gem allows us to easily and dynamically test all of the roles and profiles in our environment against fact sets from all of the nodes to which they will be applied. All we need to do is create a spec test that calls out to the `Controlrepo` ruby class:

```ruby
require 'spec_helper'
require 'controlrepo'

Controlrepo.roles.each do |role|
  describe role do
    Controlrepo.facts.each do |facts|
      context "on #{facts['fqdn']}" do
        let(:facts) { facts }
        it { should compile }
      end
    end
  end
end
```

This will iterate over each role in the controlrepo and test that it compiles with each set of facts.

The same can also be done with profiles just by using the profiles method instead:

```ruby
require 'spec_helper'
require 'controlrepo'

Controlrepo.profiles.each do |profile|
  describe profile do
    Controlrepo.facts.each do |facts|
      context "on #{facts['fqdn']}" do
        let(:facts) { facts }
        it { should compile }
      end
    end
  end
end
```

It is not limited to just doing simple "It should compile" tests. You can put any tests you want in here.

Also since the `profiles`, `roles` and `facts` methods simply return arrays, you can iterate over them however you would like i.e. you could write a different set of tests for each profile and then just use the `facts` method to run those tests on every fact set.

# Filtering

You can also filter your fact sets based on the value of any fact, including structured facts. (It will drill down into nested hashes and match those too, it's not just a dumb equality match)

Just pass a hash to the `facts` method and it will return only the fact sets with facts that match the hash e.g. Testing a certain profile on against only your Windows fact sets:

```ruby
require 'spec_helper'
require 'controlrepo'

describe 'profile::windows_appserver' do
  Controlrepo.facts({
    'kernel' => 'windows'
    }).each do |facts|
    context "on #{facts['fqdn']}" do
      let(:facts) { facts }
      it { should compile }
    end
  end
end
```

# Using hiera data

You can also point these tests at your hiera data, you do this as you [normally would](Controlrepo.new.config) with rspec tests. However we do provide one helper to make this marginally easier. `Controlrepo.hiera_config` will look for hiera.yaml in the root of your control repo and also the spec directory, you will however need to set up the file itself e.g.

```ruby
require 'controlrepo'

RSpec.configure do |c|
  c.hiera_config = Controlrepo.hiera_config_file
end
```
