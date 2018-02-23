# Onceover

*The gateway drug to automated infrastructure testing with Puppet*

Onceover is a tool to automatically run basic tests on an entire Puppet controlrepo. It includes automatic parsing the `Puppetfile`, `environment.conf` and others in order to run both basic compilation tests and also full acceptance tests!

## Table of Contents

  - [Overview](#overview)
  - [Quick Start](#quick-start)
  - [Installation](#installation)
  - [Config files](#config-files)
    - [onceover.yaml](#onceoveryaml)
    - [factsets](#factsets)
    - [nodesets](#nodesets)
    - [Hiera Data](#hiera-data)
  - [Spec testing](#spec-testing)
    - [Adding your own spec tests](#adding-your-own-spec-tests)
  - [Acceptance testing](#acceptance-testing)
  - [Using Workarounds](#using-workarounds)
  - [Extra tooling](#extra-tooling)
    - [Plugins](#plugins)
    - [Accessing Onceover in a traditional RSpec test](#accessing-onceover-in-a-traditional-rspec-test)
    - [Accessing fact sets in a traditional RSpec test](#accessing-fact-sets-in-a-traditional-rspec-test)
    - [Accessing Roles in a traditional RSpec test](#accessing-roles-in-a-traditional-rspec-test)
    - [Filtering](#filtering)
    - [Extra Configuration](#extra-configuration)
    - [Rake tasks](#rake-tasks)
      - [generate_fixtures](#generate_fixtures)

## Quick Start

**Note:** This assumes you are inside the root of your controlrepo.

Install the Gem:

`gem install onceover`

Set up your config:

`onceover init`

Run your spec tests!

`onceover run spec`

**Hint:** Don't forget you can use Bundler to install onceover by adding this to your gemfile:
```ruby
gem 'onceover'
```

Here is an example using Bundler:

Install the Gem:

`bundle install`

Set up your config:

`bundle exec onceover init`

Run your spec tests!

`bundle exec onceover run spec`

## Overview

This gem provides a toolset for testing Puppet Controlrepos (Repos used with r10k). The main purpose of this project is to provide a set of tools to help smooth out the process of setting up and running both spec and acceptance tests for a controlrepo. Due to the fact that controlrepos are fairly standardised in nature it seemed ridiculous that you would need to set up the same testing framework that we would normally use within a module for a controlrepo. This is because at this level we are normally just running very basic tests that cover a lot of code. It would also mean that we would need to essentially duplicated our `Puppetfile` into a `.fixtures.yml` file, along with a few other things.

This toolset requires some config before it can be used so definitely read that section before getting started.

## Installation

`gem install onceover`

This gem can just be installed using `gem install` however I would recommend using [Bundler](http://bundler.io/) to manage your gems.

## Config Files

This project uses one main config file to determine what classes we should be testing and how, this is [onceover.yaml](#onceoveryaml). The `onceover.yaml` config file provides information about what classes to test when, however it needs more information than that:

If we are doing spec testing we need sets of facts to compile the puppet code against, these are stored in [factsets](#factsets). (A few are provided out of the box for you)

If we are doing acceptance testing then we need information about how to spin up VMs to do the testing on, these are configured in [nodesets](#nodesets). (Once again these are auto-generated with `onceover init`)

### onceover.yaml

`spec/onceover.yaml` _(override with environment variable: `ONCEOVER_YAML`)_

Hopefully this config file will be fairly self explanatory once you see it, but basically this is the place where we define what classes we want to test and the [factsets](#factsets)/[nodesets](#nodesets) that we want to test them against. The config file must contain the following sections:

**classes:** A list (array) of classes that we want to test, usually this would be your roles, possibly profiles if you want. (If you don't know what roles and profiles are please [READ THIS](http://garylarizza.com/blog/2014/02/17/puppet-workflow-part-2/)). To make life easier you can also specify one or many **regular expressions** in this section. A good one to start with would be `/^role::/`. Regular expressions are just strings that start and end with a forward slash.

**nodes:** The nodes that we want to test against. The nodes that we list here map directly to either a [factset](#factsets) or a [nodeset](#nodesets) depending on weather we are running spec or acceptance tests respectively.

**node_groups:** The `node_groups` section is just for saving us some typing. Here we can set up groups of nodes which we can then refer to in our test matrix. We can create groups by simply specifying an array of servers to be in the group, or we can use the subtractive *include/exclude* syntax.

**class_groups:** The `class_groups` section is much the same as the `node_groups` sections, except that it creates groups of classes, not groups of nodes (duh). All the same rules apply and you can also use the *include/exclude* syntax. This, like the classes section can also accept regular expressions. This means that as long as you name your roles according to a naming convention that includes the desired operating system, you should be able to define your class groups once and never touch them again.

**test_matrix:** This where the action happens! This is the section where we set up which classes are going to be tested against which nodes. It should be an array of hashes with the following format:

```yaml
  - {nodes_to_test}: # The name of a node or node group
      classes: '{classes_to_test}' # the name of a class or
      tests: '{all_tests|acceptance|spec}' # One of the three
      {valid_option}: {value} # Check the doco for available options
```

Why an array of hashes? Well, that is so that we can refer to the same node or node group twice, which we may want/need to do.

In the example below we have referred to `centos6a` and `centos7b` in all of our tests as they are in `all_nodes`, `non_windows_servers` and `centos_severs`. However we have *left the more specific references to last*. This is because entries in the test_matrix will override entries above them if applicable. Meaning that we are still only testing each class on the two Centos servers once (Because the gem does de-duplication before running the tests), but also making sure we run `roles::frontend_webserver` twice before checking for idempotency.

**functions** In this section we can add functions that we want to mock when running spec tests. Each function takes the following agruments:
  - **type** *statement or rvalue*
  - **returns** *Optional: A value to return*

**before and after conditions** We can set before and after blocks before each spec test. Each before or after block accepts a condition. The facts of a node
are available through the `node_facts` hash.
```yaml
before:
  - "Puppet::Util::Platform.stubs(:'windows?').returns(node_facts['kernel'] == 'windows')"

after:
  - "puts 'Test finished running'"
``` 

**opts** The `opts` section overrides defaults for the `Onceover::Controlrepo` class' `opts` hash.

```yaml
opts:
  :facts_dirs:        # Remember: `opts` keys are symbols!
    - 'spec/factsets' # Limit factsets to files in this repository
  :debug: true        # set the `logger.level` to debug
```

```yaml
opts:
  # profiles include a legacy module named `site::`
  :profile_regex: '^(profile|site)::'

  # factset filenames use the extension`.facts` instead of `.json`
  :facts_files:
    - 'spec/factsets/*.facts'
```

A full example:

```yaml
classes:
  - 'roles::backend_dbserver'
  - 'roles::frontend_webserver'
  - 'roles::load_balancer'
  - 'roles::syd_f5_load_balancer'
  - 'roles::windows_server'
  - '/^role/'

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
    - '/^roles::win/'
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

functions:
  query_resources:
    type: rvalue
    returns: []

opts:
  :facts_dirs:
    - spec/factsets
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

Weather or not to check that puppet will be idempotent (Acceptance testing only)

**runs_before_idempotency** *Default: 1*

The number of runs to try before checking that it is idempotent. Required for some things that require restarts of the server or restarts of puppet. (Acceptance testing only)

**tags** *Default: nil*

One or many tags that tests in this group should be tagged with. This allows you to run only certain tests using the `--tags` command line parameter. **NOTE:** Custom spec tests will always be run as they are not subject to tags

### factsets

This gem comes with a few pre-canned factsets. These are listed under the `nodes` sections of `onceover.yaml` when you run `onceover init`. You can also add your own factsets by putting them in:

`spec/factsets/*.json`

Factsets are used by the controlrepo gem to generate spec tests, which compile a given class against a certain set of facts. To create these factsets all we need to do is log onto a real machine that has puppet installed and run:

`puppet facts`

Which will give raw json output of every fact which puppet knows about. Usually I would recommend running this on each of the types of machines that you run in your infrastructure so that you have good coverage. To make life easier you might want to direct it into a file instead of copying it from the command line:

`puppet facts > fact_set_name.json`

Once we have our factset all we need to do is copy it into `spec/factsets/` inside our controlrepo and commit it to version control. Factsets are named based on their filename, not the name of the server they came from (Although you can, if you want). i.e the following factset file:

`spec/factsets/server2008r2.json`

Would map to a node named `server2008r2` in `onceover.yaml`

### nodesets

`spec/acceptance/nodesets/onceover-nodes.yml`

Nodesets are used when running acceptance tests. They instruct the onceover gem how to spin up virtual machines to run the code on. Actually, that's a lie... What's really happening with nodesets is that we are using [Beaker](https://github.com/puppetlabs/beaker) to spin up the machines and then a combination of Beaker and RSpec to test them. But you don't need to worry about that too much. Due to the fact that we are using beaker to do the heavy lifting here the nodeset files follow the same format they would for normal Beaker tests, which at the time of writing supports the following hypervisors:

  - [VMWare Fusion](https://github.com/puppetlabs/beaker/blob/master/docs/VMWare-Fusion-Support.md)
  - [Amazon EC2](https://github.com/puppetlabs/beaker/blob/master/docs/EC2-Support.md)
  - [vSphere](https://github.com/puppetlabs/beaker/blob/master/docs/vSphere-Support.md)
  - [Vagrant](https://github.com/puppetlabs/beaker/blob/master/docs/Vagrant-Support.md)
  - [Google Compute Engine](https://github.com/puppetlabs/beaker/blob/master/docs/Google-Compute-Engine-Support.md)
  - [Docker](https://github.com/puppetlabs/beaker/blob/master/docs/Docker-Support.md)
  - [Openstack](https://github.com/puppetlabs/beaker/blob/master/docs/Openstack-Support.md)
  - [Solaris](https://github.com/puppetlabs/beaker/blob/master/docs/Solaris-Support.md)

Before we configure a hypervisor to spin up a node however, we have to make sure that it can clone from a machine which is ready. The onceover gem **requires it's VMs to have puppet pre-installed.** It doesn't matter what version of puppet, as long as it is on the PATH and the `type` setting is configured correctly i.e.

```yaml
type: AIO # For machines that have the all-in-one agent installed (>=4.0 or >=2015.2)
# OR
type: pe # For puppet enterprise agents <2015.2
# OR
type: foss # For open source puppet <4.0
```

Here is an example of a nodeset file that you can use yourselves. It uses freely available Vagrant boxes from Puppet and Virtualbox as the Vagrant provider. (`onceover init` will generate most of this for you)

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

If you have hiera data inside your controlrepo (or somewhere else) Onceover can be configured to use it. It is however worth noting the the `hiera.yaml` file that you currently use may not be applicable for testing right away. For example; if you are using `hiera-eyaml` I recommend creating a `hiera.yaml` purely for testing that simply uses the `yaml` backend, meaning that you don't need to provide the private keys to the testing machines.

It is also worth noting that any hiera hierarchies that are based on custom facts will not work unless those facts are part of your factsets. Trusted facts will also not work at all as the catalogs are being compiled without the node's certificate. In these instances it may be worth creating a hierarchy level that simply includes dummy data for testing purposes in order to avoid hiera lookup errors.

#### Creating the config file

If your `hiera.yaml` is version 4 or 5 and lives in the root of the controlrepo (as it should), Onceover will pick this up automatically. If you would like to make changes to this file for testing purposes, create a copy under `spec/hiera.yaml`. Onceover will use this version of the hiera config file first if it exists.

#### Setting the `datadir`

| Hiera Version | Config File Location | Required datadir |
|---------------|----------------------|------------------|
| 3 | `spec` folder | relative to the root of the repo e.g. `data` |
| 4 *deprecated* | Root of repo | relative to the root of the repo e.g. `data` |
| 4 *deprecated* | `spec` folder | relative to the spec folder e.g. `../data` |
| 5 | Root of repo | relative to the root of the repo e.g. `data` |
| 5 | `spec` folder | relative to the spec folder e.g. `../data` |

## Spec testing

Once you have your `onceover.yaml` and factsets set up you are ready to go with spec testing.

To run the tests:

`onceover run spec`

This will do the following things:

  1. Create a temporary directory under `.onceover`
  2. Clone all repos in the Puppetfile into the temporary directory
  3. Generate tests that use rspec-puppet
  4. Run the tests

### Adding your own spec tests

When using this gem adding your own spec tests is exactly the same as if you were to add them to a module, simply create them under `spec/{classes,defines,etc.}` in the Controlrepo and they will be run like normal, along with all of the `it { should compile }` tests.

### Exposing Puppet output

If you want to see Puppet's output, you can set the `SHOW_PUPPET_OUTPUT` environment variable to `true`, eg:

`SHOW_PUPPET_OUTPUT=true onceover run spec`

## Acceptance testing

Acceptance testing works in much the same way as spec testing except that it requires a nodeset file along with `onceover.yaml`

To run the tests:

`onceover run acceptance`

This will do the following things:

  1. Create a temporary directory under `.onceover`
  2. Clone all repos in the Puppetfile into the temporary directory
  3. Generate tests that use RSpec and Beaker
  4. Run the tests, each test consists of:
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

Fear not! There is a solution for this, it's also a good way to practice writing *nasty* puppet code. For this exact purpose I have added the ability for onceover to include extra bits of code in the tests to fix things like this. All you need to do is put a file/s containing puppet code here:

`spec/pre_conditions/*.pp`

What this will do is it will take any puppet code from any files it finds in that directory and have it executed alongside the code that you are actually testing. For example if we are testing some code that notifies the `pe-puppetserver` service, but are not managing that service in our code because it is managed by the PE module that ships with Puppet Enterprise the following code will fail:

```puppet
file { '/etc/puppetlabs/puppet/puppet.conf':
  ensure  => file,
  content => '#nothing',
  notify  => Service['pe-puppetserver'], # This will fail without the PE module!
}
```

To fix this we can add the service to the pre_conditions to make sure that our catalogs can compile e.g.

```puppet
# spec/pre_conditions/services.pp
service { 'pe-puppetserver':
  ensure => 'running',
}
```

You can also mock out defined resources or types that you cannot gain access to easily, such as `puppet_enterprise::mcollective::client`:

```puppet
  define puppet_enterprise::mcollective::client (
    $activemq_brokers,
    $logfile     = '/var/log',
    $create_user = true,
  ) {

  }
```
or

```puppet
  define pe_ini_setting (
    $ensure  = present,
    $path,
    $section,
    $setting,
    $value,
  ) {
  }
```

However this is going to pose an issue when we get to acceptance testing. Due to the fact that acceptance tests actually run the code, not just tries to compile a catalog, it will not be able to find the 'pe-pupetserver' service and will fail. One way to get around this is to use some of the optional parameters to the service resource e.g.

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

Here we are specifying custom commands to run for starting, stopping and checking the status of a service. We know what the exit codes of these commands are going to be so we know what puppet will think the service is doing because we have [read the documentation](https://docs.puppetlabs.com/references/latest/type.html#service-attributes). If there are things other than services you need to check then I would recommend checking the documentation to see if you can mock things like we have here. Alternatively you might need to create specific VM images that are pre-prepared.

[Resource collectors](https://docs.puppetlabs.com/puppet/latest/reference/lang_resources_advanced.html#amending-attributes-with-a-collector) are likely to come in handy here too. They allow you to override values of resources that match given criteria. This way we can override things for the sake of testing without having to change the code.

**NOTE:** If you need to run some pre_conditions during acceptance tests but not spec tests or vice versa you can check the status of the `$controlrepo_accpetance` variable. It will be `true` when run as an acceptance test and `undef` otherwise. If you want to limit pre_conditions to only certain nodes just use conditional logic based on facts like you normally would.

**NOTE:** If you want to access the class or factset that onceover is running against just use the `$onceover_class` and `$onceover_node` variables respectively.

## Extra Tooling

### Plugins

Onceover now allows for plugins. To use a plugin simply install a gem with a name that starts with `onceover-` and onceover will activate it.

Useful plugins:

  - [onceover-codequality](https://github.com/declarativesystems/onceover-codequality) _Check lint and syntax_
  - [onceover-octocatalog-diff](https://github.com/dylanratcliffe/onceover-octocatalog-diff) _See the differences between two versions of a catalog_

If you want to write your own plugin, take a look at [onceover-helloworld](https://github.com/declarativesystems/onceover-helloworld) to help you get started.

### Inspecting and updating the Puppetfile

Onceover comes with some extra commands for interacting with the Puppetfile in useful ways. These are:

`onceover show puppetfile`

This will display all the current versions of all modules that are in the Puppetfile alongside the latest versions and whether or not they are out of date. This is a useful took for making sure your modules don't get too stale.

`onceover update puppetfile`

This takes your Puppetfile and actually modifies all of the module versions in there to the latest versions and saves the file. This is useful for setting up automated Puppetfile updates, just get Jenkins or Bamboo to:

  1. Check out the Controlrepo
  2. Run onceover to get a passing baseline
  3. Update the Puppetfile with the latest versions of all modules
  4. Run Onceover agan
  5. Create a pull request if all tests pass

### Accessing Onceover in a traditional RSpec test

If you would like to use `onceover.yaml` to manage which tests you want to run, but want more than just `it { should_compile }` tests to be run you can write you own as follows:

```ruby
# spec/classes/role_spec.rb
require 'spec_helper'
require 'onceover/controlrepo'
require 'helpers/shared_examples'

Onceover::Controlrepo.new.spec_tests do |class_name,node_name,facts,pre_conditions|
  describe class_name do
    context "on #{node_name}" do
      let(:facts) { facts }
      let(:pre_condition) { pre_conditions }

      it_behaves_like 'soe'
    end
  end
end
```

This will use the `soe` [shared example](https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples) on all of the tests that are configured in your `onceover.yaml` including any [pre_conditions](#using-workarounds) that you have set up.

**Note:** Onceover will automatically run any extra Rspec tests that it finds in the normal directories `spec/{classes,defines,unit,functions,hosts,integration,types}` so you can easily use auto-generated spec tests in conjunction with your own Rspec tests.

### Accessing fact sets in a traditional RSpec test

We can access all of our fact sets using `Onceover::Controlrepo.facts`. Normally it would be implemented something like this:

```ruby
Onceover::Controlrepo.facts.each do |facts|
  context "on #{facts['fqdn']}" do
    let(:facts) { facts }
    it { should compile }
  end
end
```

### Other (possibly less useful) methods

The following code will test all roles that onceover can find (ignoring the ones configured in `onceover.yaml`) on all nodes in native rspec:

```ruby
require 'spec_helper'
require 'onceover/controlrepo'
Onceover::Controlrepo.roles.each do |role|
  describe role do
    Onceover::Controlrepo.facts.each do |facts|
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
require 'onceover'
Onceover::Controlrepo.profiles.each do |profile|
  describe profile do
    Onceover::Controlrepo.facts.each do |facts|
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
require 'onceover'

describe 'profile::windows_appserver' do
  Onceover::Controlrepo.facts({
    'kernel' => 'windows'
    }).each do |facts|
    context "on #{facts['fqdn']}" do
      let(:facts) { facts }
      it { should compile }
    end
  end
end
```

### Extra Configuration

You can modify the regexes that the gem uses to filter classes that it finds into roles and profiles. Just set up a Controlrepo object and pass regexes to the below settings.

```ruby
repo = Onceover::Controlrepo.new()
repo.role_regex = /.*/ # Tells the class how to find roles, will be applied to repo.classes
repo.profile_regex = /.*/ # Tells the class how to find profiles, will be applied to repo.classes
```

Note that you will need to call the `roles` and `profiles` methods on the object you just instantiated, not the main class e.g. `repo.roles` not Onceover::Controlrepo.roles

### Rake tasks

I have included a couple of little rake tasks to help get you started with testing your control repos. Set them up by adding this to your `Rakefile`

```ruby
require 'onceover/rake_tasks'
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

## Developing Onceover

Install gem dependencies:

`bundle install`

Clone the submodules

`git submodule init && git submodule update --recursive`

Execute tests

`bundle exec rake`

## Contributors

Cheers to all of those who helped out:

  - jessereynolds
  - op-ct
  - GeoffWilliams
  - beergeek
  - jairojunior
  - natemccurdy
  - aardvark
  - Mandos
  - Nekototori
