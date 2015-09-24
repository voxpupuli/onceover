# Controlreo Gem

## Configuration

```ruby
repo = Controlrepo.new()
repo.role_regex = /.*/ # Tells the class how to find roles, will be applied to repo.classes
repo.profile_regex = /.*/ # Tells the class how to find profiles, will be applied to repo.classes
```

# Running the tests

This gem allows us to easily and dynamically test all of the roles and profiles in our environment against fact sets from all of the nodes to which they will be applied. All we need to do is create a spec test that calls out to the `Controlrepo` ruby class:

```ruby
require 'spec_helper'
require 'controlrepo'

controlrepo = Controlrepo.new()

controlrepo.roles.each do |role|
  describe role do
    controlrepo.facts.each do |facts|
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

controlrepo = Controlrepo.new()

controlrepo.profiles.each do |profile|
  describe profile do
    controlrepo.facts.each do |facts|
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

controlrepo = Controlrepo.new()

describe 'profile::windows_appserver' do
  controlrepo.facts({
    'kernel' => 'windows'
    }).each do |facts|
    context "on #{facts['fqdn']}" do
      let(:facts) { facts }
      it { should compile }
    end
  end
end
```