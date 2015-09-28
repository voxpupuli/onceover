# Controlrepo Gem

## Configuration

You can modify the regexes that the gem uses to filter classes that it finds into roles and profiles. Just set up a Controlrepo object and pass regexes to the below settings. 

```ruby
repo = Controlrepo.new()
repo.role_regex = /.*/ # Tells the class how to find roles, will be applied to repo.classes
repo.profile_regex = /.*/ # Tells the class how to find profiles, will be applied to repo.classes
```

Note that you will need to call the `roles` and `profiles` methods on the object you just instantiated, not the main class e.g. `repo.roles` not `Controlrepo.roles`

# Rake tasks

I have included a couple of little rake tasks to help get you started with testing your control repos. Set them up by adding this to your `Rakefile`

```ruby
require 'controlrepo'
```

The tasks are as follows:

## generate_fixtures

`bundle exec rake generate_fixtures`

This task will go though your Puppetfile, grab all of the modules in there and convert them into a `.fixtures.yml` file. It will also take the `environment.conf` file into account, check to see if you have any relative pathed directories and also include them into the `.fixtures.yml` as symlinks. e.g. If your files look like this:

**Puppetfile**
```ruby
forge "http://forgeapi.puppetlabs.com"

# Modules from the Puppet Forge
mod "puppetlabs/stdlib", "4.6.0"
mod "puppetlabs/apache", "1.5.0"
```

**environment.conf**
```ini
modulepath = site:modules:$basemodulepath
environment_timeout = 0
```

Then the `.fixtures.yml` file that this rake task will create will look like this:

```yaml
---
fixtures:
  symlinks:
    profiles: site/profiles
    roles: site/roles
  forge_modules:
    stdlib:
      repo: puppetlabs/stdlib
      ref: 4.6.0
    apache:
      repo: puppetlabs/apache
      ref: 1.5.0
```

Notice that the symlinks are not the ones that we provided in `environment.conf`? This is because the rake task will go into each of directories, find the modules and create a symlink for each of them (This is what rspec expects).

## generate_nodesets

`bundle exec rake generate_nodesets`

This task will generate nodeset file required by beaker, based on the fact sets that exist in the repository. If you have any fact sets for which puppetlabs has a compatible vagrant box (i.e. centos, debian, ubuntu) it will detect the version specifics and set up the nodeset file, complete with box URL. If it doesn't know how to deal with a fact set it will output a boilerplate nodeset file that will need to be altered before it can be used.

## hiera_setup

`bundle exec rake hiera_setup`

Automatically modifies your hiera.yaml to point at the hieradata relative to it's position.

This rake task will look for a hiera.yaml file (Using the same method we use for [this](#using-hiera-data)). It will then look for a hieradata directory in the root for your control repo (needs to match [this](http://rubular.com/?regex=%2Fhiera%28%3F%3A.%2Adata%29%3F%2Fi)). It will then modify the datadirs of any backends it finds in `hiera.yaml` to point at these directories

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

# Fact sets

This gem introduces the concept of fact sets. Instead of manually specifying facts in each rspec test we can just dump the actual facts from the actual machines in our environment into a folder then test against them. To do this we first need to dump the facts into a json file:

`puppet facts > server01.json`

Then grab this file and put it in `spec/facts` inside your control repo. It doesn't matter what you name these files, as long as they are in that directory and the y end with `json` we will be able to find them.

**That's it!**

Now we can access all of these fact sets using `Controlrepo.facts`. Normally it would be implemented something like this:

```ruby
Controlrepo.facts.each do |facts|
  context "on #{facts['fqdn']}" do
    let(:facts) { facts }
    it { should compile }
  end
end
```

## Filtering

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

You can also point these tests at your hiera data, you do this as you [normally would](https://github.com/rodjek/rspec-puppet#enabling-hiera-lookups) with rspec tests. However we do provide one helper to make this marginally easier. `Controlrepo.hiera_config` will look for hiera.yaml in the root of your control repo and also the spec directory, you will however need to set up the file itself e.g.

```ruby
require 'controlrepo'

RSpec.configure do |c|
  c.hiera_config = Controlrepo.hiera_config_file
end
```
