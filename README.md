# Controlrepo Toolset

## Overview

This gem gives you a bunch of tools to use for testing and generally managing Puppet controlrepos. The main purpose of this project is to provide a set of tools to help smooth out the process of setting up and running both spec and acceptance tests for a controlrepo. Due to the fact that controlrepos are fairly standardise in nature it seemed ridiculous that you would need to set up the same testing framework that we would normally use within a module for a controlrepo. This is because at this level we are normally just running very basic tests that test a lot of code. It would also mean that we would need to essentially duplicated our `Puppetfile` into a `.fixtures.yml` file, along with a few other things.

This toolset has two distinct ways of being used, easy mode and hard mode.

### Easy Mode

The object of *easy mode* is to allow people to run simple `it { should compile }` acceptance tests without needing to set up any of the extra stuff required by the rspec-puppet testing framework.

`rake tasks go here once they are done`

A stretch goal is to also include acceptance testing, allowing people to spin up boxes for each role they have and test them before merging code into development environments or production. At the moment we can't do this, hold tight.

#### Easy mode config

The whole idea of easy mode is that we should just be able to write down which classes we want to test on which machines and this tool should be able to do the rest. This all has to be set up somewhere, this is **spec/controlrepo.yaml** which looks something like this:

```yaml
classes:
  - 'roles::backend_dbserver'
  - 'roles::frontend_webserver'
  - 'roles::load_balancer'
  - 'roles::syd_f5_load_balancer'
  - 'roles::windows_server'

nodes:
  - centos6a
  - centos7b
  - server2008r2a
  - ubuntu1404a

groups:
  windows_roles:
    - 'roles::windows_server'
    - 'roles::backend_dbserver'
  centos_servers:
    - centos6a
    - centos7b

test_matrix:
  server2008r2a: windows_roles
  ubuntu1404a: 'roles::frontend_webserver'
  centos_servers:
    include: all_classes
    exclude: windows_roles
```

It consists of the following sections:

##### Classes:

This is where we list all of the classes that we want to test, normally this will just be a list of roles. Note that these classes must *actually exist* for reasons that should be obvious.

##### Nodes:

Each node in the list refers one of two things depending on weather we are running **spec** or **acceptance** tests. If we are running **spec** tests each node refers to the name of a [fact set](#fact-sets) because this will be the set of facts that the `it { should compile }` test will be run against. If we are are running **acceptance** tests then each node will refer to a *nodeset* file which we can generate (or at least try to) using the `generate_nodesets` rake task. For acceptance testing the nodeset file will tell us how to spin up the VMs for each machine.

##### Groups:

Groups are used to save us a bit of time and code (if you can call yaml that). Unsurprisingly a group is a way to bundle either classes or nodes into a group that we can refer to but it's name instead of repeating ourselves a whole bunch. There are 2 **default groups:**

  - all_nodes
  - all_classes

You can guess what they are for I hope.

*Note that groups CANNOT contain a mix of classes and nodes, only one or the other.*

##### Test Matrix:

This is the section of th config file that makes the magic happen. In the test matrix we choose on which nodes we will tests which classes. You can use groups anywhere here as you can see in the example above. We also have the option of using *include* and *exclude* which will be useful if you have a lot of groups.

For example if we want to test all our non-windows roles on all of our linux boxes we can do something like this:

```yaml
test_matrix:
  linux_nodes:
    include: 'all_classes'
    exclude: 'windows_roles'
```

This is assuming that you have all of your linux nodes in the `linux_nodes` group and all of your Windows roles in the `windows_roles` group.

When setting up your tests matrix don't worry too much about using groups that will cause duplicate combinations of `node -> class` pairs. The rake tasks run deduplication before running any of the tests to make sure that we are not wasting time. This happens at runtime and does not affect the file or anything.

### Hard mode

The point of *hard mode* is to give people who are familiar with RSpec testing with puppet a set of useful tools that they can mix into their tests to save some hassle. We also want to help in getting your tests set up by automatically generating `.fixtures.yml` and nodesets.

## Fact sets

This gem introduces the concept of fact sets. Instead of manually specifying facts in each rspec test we can just dump the actual facts from the actual machines in our environment into a folder then test against them. To do this we first need to dump the facts into a json file:

`puppet facts > server01.json`

Then grab this file and put it in `spec/facts` inside your control repo. It doesn't matter what you name these files, as long as they are in that directory and they end with `json` we will be able to find them. Fact sets are also heavily used by **easy mode**.

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


## Rake tasks

I have included a couple of little rake tasks to help get you started with testing your control repos. Set them up by adding this to your `Rakefile`

```ruby
require 'controlrepo'
```

The tasks are as follows:

### generate_fixtures

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

### generate_nodesets

`bundle exec rake generate_nodesets`

This task will generate nodeset file required by beaker, based on the fact sets that exist in the repository. If you have any fact sets for which puppetlabs has a compatible vagrant box (i.e. centos, debian, ubuntu) it will detect the version specifics and set up the nodeset file, complete with box URL. If it doesn't know how to deal with a fact set it will output a boilerplate nodeset file that will need to be altered before it can be used.

### hiera_setup

`bundle exec rake hiera_setup`

Automatically modifies your hiera.yaml to point at the hieradata relative to it's position.

This rake task will look for a hiera.yaml file (Using the same method we use for [this](#using-hiera-data)). It will then look for a hieradata directory in the root for your control repo (needs to match [this](http://rubular.com/?regex=%2Fhiera%28%3F%3A.%2Adata%29%3F%2Fi)). It will then modify the datadirs of any backends it finds in `hiera.yaml` to point at these directories.

## Running the tests (Hard mode)

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

## Filtering (Hard mode)

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

## Using hiera data (Hard Mode)

You can also point these tests at your hiera data, you do this as you [normally would](https://github.com/rodjek/rspec-puppet#enabling-hiera-lookups) with rspec tests. However we do provide one helper to make this marginally easier. `Controlrepo.hiera_config` will look for hiera.yaml in the root of your control repo and also the spec directory, you will however need to set up the file itself e.g.

```ruby
require 'controlrepo'

RSpec.configure do |c|
  c.hiera_config = Controlrepo.hiera_config_file
end
```


## Extra Configuration

You can modify the regexes that the gem uses to filter classes that it finds into roles and profiles. Just set up a Controlrepo object and pass regexes to the below settings.

```ruby
repo = Controlrepo.new()
repo.role_regex = /.*/ # Tells the class how to find roles, will be applied to repo.classes
repo.profile_regex = /.*/ # Tells the class how to find profiles, will be applied to repo.classes
```

Note that you will need to call the `roles` and `profiles` methods on the object you just instantiated, not the main class e.g. `repo.roles` not `Controlrepo.roles`

