# Controlrepo Toolset

## Table of Contents

  - [Overview](#overview)
  - [Quick Start](#quick-start)
  - [Installation](#installation)
  - [Config files](#config-files)
    - [controlrepo.yaml](#controlrepoyaml)
    - [factsets](#factsets)
    - [nodesets](#nodesets)
    - [Hiera Data](#hiera-data)
    - [R10k.yaml](#r10kyaml)
  - [Spec testing](#spec-testing)
    - [Adding your own spec tests](#adding-your-own-spec-tests)
  - [Acceptance testing](#acceptance-testing)
  - [Using Workarounds](#using-workarounds)
  - [Extra tooling](#extra-tooling)
    - [Accessing fact sets in a traditional RSpec test](#accessing-fact-sets-in-a-traditional-rspec-test)
    - [Accessing Roles in a traditional RSpec test](#accessing-roles-in-a-traditional-rspec-test)
    - [Filtering](#filtering)
    - [Using hiera data (In manual tests)](#using-hiera-data-in-manual-tests)
    - [Extra Configuration](#extra-configuration)
    - [Rake tasks](#rake-tasks)
      - [generate_fixtures](#generate_fixtures)
      - [generate_controlrepo_yaml](#generate_controlrepo_yaml)
      - [generate_nodesets](#generate_nodesets)
      - [hiera_setup](#hiera_setup)

## Quick Start

**Note:** This assumes you are inside the controlrepo directory.

Add this to your `Gemfile`:

```ruby
source 'https://rubygems.org'

gem 'controlrepo'
```

Install all the gems:

`bundle install`

Add this to your [Rakefile](#rake-tasks):

```ruby
require 'controlrepo/rake_tasks'
```

Create directories:

`mkdir -p spec/acceptance/nodesets`

Generate your [controlrepo.yaml](#controlrepoyaml):

`bundle exec rake generate_controlrepo_yaml > spec/controlrepo.yaml`

Generate your [nodesets](#nodesets):

`bundle exec rake generate_nodesets > spec/acceptance/nodesets/controlrepo-nodes.yml`

*Optional:* [Get hiera working](#hiera-data)

Run spec tests:

`bundle exec rake controlrepo_spec`

Run acceptance tests:

`bundle exec rake controlrepo_acceptance`

## Overview

This gem provides a toolset for testing Puppet Controlrepos (Repos used with r10k). The main purpose of this project is to provide a set of tools to help smooth out the process of setting up and running both spec and acceptance tests for a controlrepo. Due to the fact that controlrepos are fairly standardised in nature it seemed ridiculous that you would need to set up the same testing framework that we would normally use within a module for a controlrepo. This is because at this level we are normally just running very basic tests that test a lot of code. It would also mean that we would need to essentially duplicated our `Puppetfile` into a `.fixtures.yml` file, along with a few other things.

This toolset requires some config before it can be used so definitely read that section before getting started.

## Installation

`gem install controlrepo`

This gem can just be installed using `gem install` however I would recommend using [Bundler](http://bundler.io/) to manage your gems.

## Config Files

This project uses one main config file to determine what classes we should be testing and how, this is [controlrepo.yaml](#controlrepo.yaml). The `controlrepo.yaml` config file provides information about what classes to test when, however it needs more information than that:

If we are doing spec testing we need sets of facts to compile the puppet code against, these are stored in [factsets](#factsets).

If we are doing acceptance testing then we need information about how to spin up VMs to do the testing on, these are configured in [nodesets](#nodesets).

There is one thing that is not configured using config files and that is the **environment** to test. To change the environment that tests run in simply use the `CONTROLREPO_env` environment variable e.g.

`CONTROLREPO_env=development bundle exec rake controlrepo_spec`

### controlrepo.yaml

`spec/controlrepo.yaml`

Hopefully this config file will be fairly self explanatory once you see it, but basically this is the place where we define what classes we want to test and the [factsets](#factsets)/[nodesets](#nodesets) that we want to test them against. The config file must contain the following sections:

**classes:** A list (array) of classes that we want to test, usually this would be your roles, possibly profiles if you want. (F you don't know what roles and profiles are please [READ THIS](http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-2/))

**nodes:** The nodes that we want to test against. The nodes that we list here map directly to either a [factset](#factsets) or a [nodeset](#nodesets) depending on weather we are running spec or acceptance tests respectively.

**node_groups:** The `node_groups` section is just for saving us some typing. Here we can set up groups of nodes which we can then refer to in our test matrix. We can create groups by simply specifying an array of servers to be in the group, or we can use the subtractive *include/exclude* syntax.

**class_groups:** The `class_groups` section is jmuch the same as the `node_groups` sections, except that it creates groups of classes, not groups of nodes (duh). All the same rules apply and you can also use the *include/exclude* syntax.

**test_matrix:** This where the action happens! This is the section where we set up which classes are going to be tested against which nodes. It should be an array of hashes with the following format:

```yaml
  - {nodes_to_test}:
      classes: '{classes_to_test}'
      tests: '{all_tests|acceptance|spec}' # One of the three
      {valid_option}: {value} # Check the doco for available options
```

Why an array of hashes? Well, that is so that we can refer to the same node or node group twice, which we may want/need to do. In the example below we have not referred to the same group twice but we have referred to `centos6a` and `centos7b` in all of out tests as they are in `all_nodes`, `non_windows_servers` and `centos_severs`. However we have left the more specific references to last. This is because entries in the test_matrix will override entries above them if applicable. Meaning that we are still only testing each class on the two centos servers once (Because the gem does de-duplication before running the tests), but also making sure we run `roles::frontend_webserver` twice before checking for idempotency.

A full example:

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

node_groups:
  centos_severs:
    - centos6a
    - centos7b
  non_windows_servers:
    include: 'all_nodes'
    exclude: 'server2008r2a'

class_groups:
  windows_roles:
    - 'roles::windows_server'
    - 'roles::backend_dbserver'
  non_windows_roles:
    include: 'all_classes'
    exclude: 'windows_roles'

test_matrix:
  - all_nodes:
      classes: 'all_classes'
      tests: 'spec'
  - non_windows_servers:
      classes: 'all_classes'
      tests: 'all_tests'
  - centos_severs:
      classes: 'roles::frontend_webserver'
      tests: 'acceptance'
      runs_before_idempotency: 2
      tags:
        - 'frontend'
```

**Include/Exclude syntax:** This can be used with either `node_groups` or `class_groups` and allows us to save some time by using existing groups to create new ones e.g.

```yaml
node_groups:
  windows_nodes: # This has to be defined first
    - sevrer2008r2
    - server2012r2
  non_windows:
    include: 'all_nodes' # Start with all nodes
    exclude: 'windows_nodes' # Then remove the windows ones from that list
```

It's important to note that in order to reference a group using the *include/exclude* syntax is has to have been defined already i.e. it has to come above the group that references it (Makes sense right?)

#### Optional test parameters

**check_idempotency** *Default: true*

Weather or not to check that puppet will be idempotent

**runs_before_idempotency** *Default: 1*

The number of runs to try before checking that it is idempotent. Required for some things that require restarts of the server or restarts of puppet.

**tags** *Default: nil*

One or many tags that tests in this group should be tagged with. This allows you to run only certain tests using the `--tags` command line parameter.

### factsets

This gem comes with a few pre-canned factsets. These are listed under `nodes` when you run `bundle exec rake generate_controlrepo_yaml`. You can also add your own factsets by putting them in:

`spec/factsets/*.yaml`

Factsets are used by the controlrepo gem to generate spec tests, which compile a given class against a certain set of facts. To create these factsets all we need to do is log onto a real machine that has puppet installed and run:

`puppet facts`

Which will give raw json output of every fact which puppet knows about. Usually I would recommend running this on each of the types of machines that you run in your infrastructure so that you have a good coverage. To make life easier you might want to direct it into a file instead of copying it from the command line:

`puppet facts > fact_set_name.json`

Once we have our factset all we need to do is copy it into `spec/factsets/` inside out controlrepo and commit it to version control. Factsets are named based on their filename, not the name of the server they came from (Although you can, if you want). i.e the following factset file:

`spec/factsets/server2008r2.yaml`

Would map to a node named `server2008r2` in `controlrepo.yaml`

### nodesets

`spec/acceptance/nodesets/controlrepo-nodes.yml`

Nodesets are used when running acceptance tests. They instruct the controlrepo gem how to spin up virtual machines to run the code on. Actually, that's a lie... What's really happening with nodesets is that we are using [Beaker](https://github.com/puppetlabs/beaker) to spin up the machines and then a combination of Beaker and RSpec to test them. But you don't need to worry about that too much. Due to the fact that we are using beaker to do the heavy lifting here the nodeset files follow the same format they would for normal Beaker tests, which at the time of writing supports the following hypervisors:

  - [VMWare Fusion](https://github.com/puppetlabs/beaker/blob/master/docs/VMWare-Fusion-Support.md)
  - [Amazon EC2](https://github.com/puppetlabs/beaker/blob/master/docs/EC2-Support.md)
  - [vSphere](https://github.com/puppetlabs/beaker/blob/master/docs/vSphere-Support.md)
  - [Vagrant](https://github.com/puppetlabs/beaker/blob/master/docs/Vagrant-Support.md)
  - [Google Compute Engine](https://github.com/puppetlabs/beaker/blob/master/docs/Google-Compute-Engine-Support.md)
  - [Docker](https://github.com/puppetlabs/beaker/blob/master/docs/Docker-Support.md)
  - [Openstack](https://github.com/puppetlabs/beaker/blob/master/docs/Openstack-Support.md)
  - [Solaris](https://github.com/puppetlabs/beaker/blob/master/docs/Solaris-Support.md)

Before we configure a hypervisor to spin up a node however, we have to make sure that it can clone from a machine which is ready. The controlrepo gem **requires it's VMs to have puppet pre-installed.** It doesn't matter what version of puppet, as long as it is on the PATH and the `type` setting is configured correctly i.e.

```yaml
type: AIO # For machines that have the all-in-one agent installed (>=4.0 or >=2015.2)
# OR
type: pe # For puppet enterprise agents <2015.2
# OR
type: foss # For open source puppet <4.0
```

Here is an example of a nodeset file that you can use yourselves. It uses freely available Vagrant boxes from puppetlabs and Virtualbox as the Vagrant provider.

```yaml
HOSTS:
  centos6a:
    roles:
      - agent
    type: aio
    platform: el-6-64
    box: puppetlabs/centos-6.6-64-puppet
    box_url: https://atlas.hashicorp.com/puppetlabs/boxes/centos-6.6-64-puppet
    hypervisor: vagrant_virtualbox
  centos7b:
    roles:
      - agent
    type: aio
    platform: el-7-64
    box: puppetlabs/centos-7.0-64-puppet
    box_url: https://atlas.hashicorp.com/puppetlabs/boxes/centos-7.0-64-puppet
    hypervisor: vagrant_virtualbox
  ubuntu1204:
    roles:
      - agent
    type: aio
    platform: ubuntu-12.04-32
    box: puppetlabs/ubuntu-12.04-32-puppet
    box_url: https://atlas.hashicorp.com/puppetlabs/boxes/ubuntu-12.04-32-puppet
    hypervisor: vagrant_virtualbox
  debian78:
    roles:
      - agent
    type: aio
    platform: debian-7.8-64
    box: puppetlabs/debian-7.8-64-puppet
    box_url: https://atlas.hashicorp.com/puppetlabs/boxes/debian-7.8-64-puppet
    hypervisor: vagrant_virtualbox
```

### Hiera Data

If you have hiera data inside your controlrepo (or somewhere else) the Controlrepo gem can be configured to use it. Just dump your `hiera.yaml` file from the puppet master into the `spec/` directory and you are good to go. **NOTE:** This assumes that the path to your hiera data (datadir) is relative to the root of the controlrepo, if not it will fall over.

Alternatively, if you are using cool new per-environment hiera config, the toll will automatically detect this and everything should work.

### R10k.yaml

For the Controlrepo gem to be able to clone the controlrepo (itself) from git (into a temp dir) it needs an `r10k.yaml` file under the `spec/` directory. Don't worry about any of the paths here, we dynamically generate and override them. I realise that this is kind of redundant and will be looking into changing it in the future.

## Spec testing

Once you have your `controlrepo.yaml` and factsets set up you are ready to go with spec testing.

To run the tests:

`bundle exec rake controlrepo_spec`

This will do the following things:

  1. Create a temporary directory
  2. Clone all repos in the Puppetfile into the temporary directory
  3. Generate tests that use rspec-puppet
  4. Install required gems into temp dir using Bundler
  5. Run the tests

### Adding your own spec tests

When using this gem adding your own spec tests is exactly the same as if you were to add them to a module, simply create them under `spec/{classes,defines,etc.}` in the Controlrepo and they will be run like normal, along with all of the `it { should compile }` tests.

## Acceptance testing

Acceptance testing works in much the same way as spec testing except that it requires a nodeset file along with `controlrepo.yaml`

To run the tests:

`bundle exec rake controlrepo_acceptance`

This will do the following things:

  1. Create a temporary directory
  2. Clone all repos in the Puppetfile into the temporary directory
  3. Generate tests that use RSpec and Beaker
  4. Install required gems into temp dir using Bundler
  5. Run the tests, each test consists of:
    - Spin up the VM
    - Copy over the code
    - Run puppet and catch any errors
    - Run puppet again to catch anything that might not be idempotent
    - Destroy the VM

## Using workarounds

There may be situations where you cannot test everything that is in your puppet code, some common reasons for this include:

  - Code is destined for a Puppet Master but the VM image is not a Puppet Master which means we can't restart certain services etc.
  - A file is being pulled from somewhere that is only accessible in production
  - Something is trying to connect to something else that does not exist

Fear not! There is a solution for this, it's also a good way to practice writing *nasty* puppet code. For this exact purpose I have added the ability for the controlrepo gem to include extra bits of code in the tests to fix things. All you need to do is put a file containing puppet code here:

`spec/pre_conditions/*.pp`

What this will do is it will take any puppet code from any files it finds in that directory and have it executed alongside the code that you are actually testing. For example if we are testing some code that notifies the `pe-puppetserver` service, but are not managing that service in our code because it is managed by the PE module that ships with Puppet Enterprise:

```puppet
# Somewhere in our code
file { '/etc/puppetlabs/puppet/puppet.conf':
  ensure  => file,
  content => '#nothing',
  notify  => Service['pe-puppetserver'], # This will fail without the PE module!
  }
```

We can add the service to the pre_conditions to make sure that out catalogs can compile e.g.

```puppet
# spec/pre_conditions/services.pp
service { 'pe-puppetserver':
  ensure => 'running',
}
```

However this is going to pose an issue when we get to acceptance testing. Due to the fact that acceptance tests actually run the code, not just try to compile a catalog, it will not be able to find the 'pe-pupetserver' service and will fail. One way to get around this is to use some of the optional parameters to the service resource e.g.

```puppet
# We are not going to actually have this service anywhere on our servers but
# our code needs to refresh it. This is to trick puppet into doing nothing
service { 'pe-puppetserver':
  ensure     => 'running',
  enable     => false,
  hasrestart => false, # Force Puppet to use start and stop to restart
  start      => 'echo "Start"', # This will always exit 0
  stop       => 'echo "Stop"', # This will also always exit 0
  hasstatus  => false, # Force puppet to use our command for status
  status     => 'echo "Status"', # This will always exit 0 and therefore Puppet will think the service is running
  provider   => 'base',
}
```

Here we are specifying custom commands to run for starting, stopping and checking the status of a service. We know what the exit codes of these commands are going to be so we know what puppet will think the service is doing because we have [read the documentation](https://docs.puppetlabs.com/references/latest/type.html#service-attributes). If there are things other than services you need to check then I would recommend checking the documentation to see if you can mock things like we have here.

[Resource collectors](https://docs.puppetlabs.com/puppet/latest/reference/lang_resources_advanced.html#amending-attributes-with-a-collector) are likely to come in handy here too. They allow you to override values of resources that match given criteria. This way we can override things for the sake of testing without having to change the code.

**NOTE:** If you need to run some pre_conditions during acceptance tests but not spec tests or vice versa you can check the status of the `$controlrepo_accpetance` variable. It will be `true` when run as an acceptance test and `undef` otherwise. If you want to limit pre_conditions to only certain nodes just use conditional logic based on facts like you normally would.

## Extra Tooling

I have provided some extra tools to use if you would prefer to write your own tests which I will go over here.

### Accessing fact sets in a traditional RSpec test

We can access all of our fact sets using `Controlrepo.facts`. Normally it would be implemented something like this:

```ruby
Controlrepo.facts.each do |facts|
  context "on #{facts['fqdn']}" do
    let(:facts) { facts }
    it { should compile }
  end
end
```

### Accessing Roles in a traditional RSpec test

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

### Filtering

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

### Using hiera data (In manual tests)

You can also point these tests at your hiera data, you do this as you [normally would](https://github.com/rodjek/rspec-puppet#enabling-hiera-lookups) with rspec tests. However we do provide one helper to make this marginally easier. `Controlrepo.hiera_config` will look for hiera.yaml in the root of your control repo and also the spec directory, you will however need to set up the file itself e.g.

```ruby
require 'controlrepo'

RSpec.configure do |c|
  c.hiera_config = Controlrepo.hiera_config_file
end
```

### Extra Configuration

You can modify the regexes that the gem uses to filter classes that it finds into roles and profiles. Just set up a Controlrepo object and pass regexes to the below settings.

```ruby
repo = Controlrepo.new()
repo.role_regex = /.*/ # Tells the class how to find roles, will be applied to repo.classes
repo.profile_regex = /.*/ # Tells the class how to find profiles, will be applied to repo.classes
```

Note that you will need to call the `roles` and `profiles` methods on the object you just instantiated, not the main class e.g. `repo.roles` not `Controlrepo.roles`

### Rake tasks

I have included a couple of little rake tasks to help get you started with testing your control repos. Set them up by adding this to your `Rakefile`

```ruby
require 'controlrepo/rake_tasks'
```

The tasks are as follows:

#### generate_fixtures

`bundle exec rake generate_fixtures`

This task will go though your Puppetfile, grab all of the modules in there and convert them into a `.fixtures.yml` file. (You only need this if you are writing your own custom spec tests) It will also take the `environment.conf` file into account, check to see if you have any relative pathed directories and also include them into the `.fixtures.yml` as symlinks. e.g. If your files look like this:

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

#### generate_controlrepo_yaml

`bundle exec rake generate_controlrepo_yaml`

This will try to generate a `controlrepo.yaml` file, it will:

  - Parse your environment.conf to work out where your roles and profiles might live
  - Find your roles classes and pre-polulate them into the "classes" section
  - Look though all of the factsets that ship with the gem, and also the ones you have created under `spec/factsets/*.json`
  - Populate the "nodes" section with all of the factsets it finds
  - Create node groups of windows and non-windows nodes
  - Create a basic test_matrix


#### generate_nodesets

`bundle exec rake generate_nodesets`

This task will generate nodeset file required by beaker, based on the factsets that exist in the repository. If you have any fact sets for which puppetlabs has a compatible vagrant box (i.e. centos, debian, ubuntu) it will detect the version specifics and set up the nodeset file, complete with box URL. If it doesn't know how to deal with a fact set it will output a boilerplate nodeset section and comment it out.

#### hiera_setup

`bundle exec rake hiera_setup`

Automatically modifies your hiera.yaml to point at the hieradata relative to it's position.

This rake task will look for a hiera.yaml file (Using the same method we use for [this](#using-hiera-data)). It will then look for a hieradata directory in the root for your control repo (needs to match [this](http://rubular.com/?regex=%2Fhiera%28%3F%3A.%2Adata%29%3F%2Fi)). It will then modify the datadirs of any backends it finds in `hiera.yaml` to point at these directories.
