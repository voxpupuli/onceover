# Onceover

*The gateway drug to automated infrastructure testing with Puppet*

Onceover is a tool to automatically run basic tests on an entire Puppet control repository.

It includes automatic parsing of the `Puppetfile`, `environment.conf` and others in order to stop silly mistakes ever reaching your Puppet Master!

**New in v3.19.1: I've reversed the decision to have onceover use `site.pp` in the same way Puppet does. From now on your `manifest` setting in `environment.conf` will be ignored and your `site.pp` will only be used if you explicitly set the `manifest` option in the CLI or config file.**

[![Build Status](https://travis-ci.com/dylanratcliffe/onceover.svg?branch=master)](https://travis-ci.com/dylanratcliffe/onceover) [![Build status](https://ci.appveyor.com/api/projects/status/2ys2ggkgln69hmyf/branch/master?svg=true)](https://ci.appveyor.com/project/dylanratcliffe/onceover/branch/master)

## Table of Contents

  - [Overview](#overview)
  - [Quick Start](#quick-start)
  - [Configuration](#configuration)
    - [onceover.yaml](#onceoveryaml)
    - [Factsets](#factsets)
    - [Hiera](#hiera)
    - [Puppetfile](#puppetfile)
  - [Spec testing](#spec-testing)
    - [Adding your own spec tests](#adding-your-own-spec-tests)
  - [Using Workarounds](#using-workarounds)
  - [Extra tooling](#extra-tooling)
    - [Plugins](#plugins)
    - [Overriding Onceover's Templates](#overriding-onceovers-templates)
    - [Accessing Onceover in a traditional RSpec test](#accessing-onceover-in-a-traditional-rspec-test)
    - [Accessing fact sets in a traditional RSpec test](#accessing-fact-sets-in-a-traditional-rspec-test)
    - [Accessing Roles in a traditional RSpec test](#accessing-roles-in-a-traditional-rspec-test)
    - [Filtering](#filtering)
    - [Extra Configuration](#extra-configuration)
    - [Ruby Warnings](#ruby-warnings)
    - [Rake tasks](#rake-tasks)
      - [generate_fixtures](#generate_fixtures)

## Overview

This gem provides a toolset for testing _Puppet control repository_ (ie. Repos used with r10k).

The main purpose of this project is to provide a set of tools to help smooth out the process of setting up and running `rspec-puppet` tests for a controlrepo.

Due to the fact that controlrepos are fairly standardised in nature it seemed ridiculous that you would need to set up the same testing framework that we would normally use within a module for a controlrepo. This is because at this level we are normally just running very basic tests that cover a lot of code. It would also mean that we would need to essentially duplicated our `Puppetfile` into a `.fixtures.yml` file, along with a few other things.

This toolset requires some [configuration](#configuration) before it can be used so definitely read that section before getting started.

## Quick Start

**Note:** This assumes you are inside the root of your control-repo.

1. Add `onceover` to your `Gemfile`:

    ```ruby
    gem 'onceover'
    ```

1. Run _Bundler_ to install `onceover`

    ```shell
    bundle install
    ```

1. Set up your configuration

    ```shell
    bundle exec onceover init
    ```
1. Run your spec tests!

    ```shell
    bundle exec onceover run spec
    ```

## Configuration

This project uses one main config file to determine what Puppet classes we should be testing and how: [onceover.yaml](#onceoveryaml).

As `onceover` tests Puppet classes, it need sets of facts to compile the Puppet code against, these are stored in [factsets](#factsets).

### onceover.yaml

Usually located at `spec/onceover.yaml`, this path could be overrided with environment variable: `ONCEOVER_YAML`.

Hopefully this config file will be fairly self explanatory once you see it, but basically this is the place where we define what classes we want to test and the [factsets](#factsets) that we want to test them against.

#### Main settings

- `classes`

    A list (array) of classes that we want to test

    Classes are specified as string or **regular expressions**.
    The recommended setting to have a good coverage is `/^role::/` if you use [roles and profiles method](https://puppet.com/docs/pe/latest/the_roles_and_profiles_method.html) and if you dont, you [should](https://puppet.com/docs/pe/2019.8/the_roles_and_profiles_method.html).

- `nodes`

    A list (array) of nodes that we want to test against.

    The nodes that we list here map directly to a [factset](#factsets), e.g. `Debian-7.8-64`

- `node_groups`

    An hash of named node groups.

    We can create groups by simply specifying an array of nodes to be in the group, or use the subtractive [include/exclude syntax](#includeexclude-syntax).

    **Note:** A _node group_ named `all_nodes` is automatically created by `onceover`.

    **Important:** The names used for the actual `class_groups` and `node_groups` must be unique.

- `class_groups`

    An hash of named class groups.

    We can create groups by simply specifying an array of classes (string or regexp) to be in the group, or use the subtractive [include/exclude syntax](#includeexclude-syntax).

    **Note:** A _class group_ named `all_classes` is automatically created by `onceover`.

    **Important:** The names used for the actual `class_groups` and `node_groups` must be unique.

- `test_matrix`

    An array of hashes with the following format:

    ```yaml
      - {nodes_to_test}: # The name of a node or node group
          classes: '{classes_to_test}' # the name of a class or
          tests: '{all_tests|acceptance|spec}' # acceptance deprecated/broken, set to spec
          {valid_option}: {value} # See below
    ```

    Valid options:

    - `tags`

        Default: `nil`

       One or many tags that tests in this group should be tagged with.
       This allows you to run only certain tests using the `--tags` command line parameter.

#### Advanced settings

- `functions`

    Default: `nil`

    In this section we can add functions that we want to mock when running spec tests.

    Each function takes the `returns` arguments, e.g.

    ```yaml
    functions:
      puppetdb_query:
        returns: []
    ```

- `before`

    Default: `nil`

    A block to run **before** each spec test.

    For example, this can be used when the functions to stub are conditional, the following stub function `x` if the OS is windows, stub function `y` if the fact `java_installed` is true.

    **Note**: The facts are available through the `node_facts` hash and the trusted facts as `trusted_facts`.

    Example:
    ```yaml
    before:
      - "Puppet::Util::Platform.stubs(:'windows?').returns(node_facts['kernel'] == 'windows')"
    ```

- `after`

    Default: `nil`

    A block to run **after** each spec test.

    **Note**: The facts are available through the `node_facts` hash and the trusted facts as `trusted_facts`.

    Exmaple:
    ```yaml
    after:
      - "puts 'Test finished running'"
    ```

- `include_spec_files`

    Default: `[**/*]`

    Glob to select additionnal files to be run during `onceover` spec tests.

    Default is to select all files located in the repo spec directory, usually `spec/`.
    If you have some RSpec tests that depend on a different RSpec configuration than `onceover` or want, for example, to have a different job in your CI to run your own unit tests, you can use this option to select which spec files to run during `onceover` spec tests.

- `opts`

    Default: `{}`

    This setting overrides defaults for the `Onceover::Controlrepo` class' `opts` hash.

    Example:
    ```yaml
    opts:
      :facts_dirs:                           # Remember: `opts` keys are symbols!
        - 'spec/factsets'                    # Limit factsets to files in this repository
      :debug: true                           # Set the `logger.level` to debug
      :profile_regex: '^(profile|site)::'    # Profiles include a legacy module named `site::`
      :facts_files:                          # Factset filenames use the extension`.facts` instead of `.json`
        - 'spec/factsets/*.facts'
      :manifest: 'manifests/site.pp'         # Manifest to use while compiling (nil by default)
    ```

#### Include/Exclude syntax

This can be used with either `node_groups` or `class_groups` and allows us to save some time by using existing groups to create new ones e.g.

```yaml
node_groups:
  windows_nodes: # This has to be defined first
    - sevrer2008r2
    - server2012r2
  non_windows:
    include: 'all_nodes' # Start with all nodes
    exclude: 'windows_nodes' # Then remove the windows ones from that list
```

It's important to note that in order to reference a group using the *include/exclude* syntax it has to have been defined already i.e. it has to come above the group that references it

#### Examples

##### Minimal

```yaml
classes:
  - /^role::/

nodes:
  - Debian-10-amd64

test_matrix:
  - all_nodes:
      classes: 'all_classes'
      tests: 'spec'
```

##### Advanced

In the example below we have referred to `centos6a` and `centos7b` in all of our tests as they are in `all_nodes`, `non_windows_servers` and `centos_severs`. However we have *left the more specific references to last*. This is because entries in the test_matrix will override entries above them if applicable. Meaning that we are still only testing each class on the two Centos servers once (Because the gem does de-duplication before running the tests), but also making sure we run `roles::frontend_webserver` twice before checking for idempotency.

A full example:

```yaml
classes:
  - 'roles::backend_dbserver'
  - 'roles::frontend_webserver'
  - 'roles::load_balancer'
  - 'roles::syd_f5_load_balancer'
  - 'roles::windows_server'
  - '/^role/'                     # Note that this regex format requires `/`

nodes:
  - centos6a
  - centos7b
  - server2008r2a
  - ubuntu1404a
  - ubuntu1604a

node_groups:
  centos_severs:
    - centos6a
    - centos7b
  ubuntu_servers:
    - ubuntu1404a
    - ubuntu1604a
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
      classes: 'non_windows_roles'
  - ubuntu_servers:
      classes: 'all_classes'
      tests: 'spec'
  - centos_severs:
      classes: 'roles::frontend_webserver'
      tests: 'spec'
      runs_before_idempotency: 2
      tags:
        - 'frontend'

functions:
  query_resources:
    returns: []
  profile::custom_function:
    returns: ["one", "two"]

opts:
  :facts_dirs:
    - spec/factsets
  :profile_regex: '^(profile|site)::'   # Note that this regex _doesn't_ use `/`
```

### Factsets

Factsets are used by the onceover gem to generate spec tests, which compile a given class against a certain set of facts.

This gem comes with a few pre-canned factsets, these are listed under the `nodes` sections of `onceover.yaml` when you run `onceover init`.

You can, and its a good pratice, add your own factsets by putting them in `spec/factsets/*.json`.

To generate these factsets all we need to do is log onto a real machine that has puppet installed and run:

```shell
puppet facts > fact_set_name.json
```

Its recommended to run this on each of the types of nodes that you run in your infrastructure to have good coverage.

If you are using [Trusted Facts](#trusted-facts) or [Trusted External Data](#trusted-external-data) and can use the [PE client tools](https://puppet.com/docs/pe/latest/installing_pe_client_tools.html) you can generate a factset which contains this information by running:

```shell
puppet facts --terminus puppetdb > fact_set_name.json
```

or

```shell
puppet facts --terminus puppetdb <node certname> > fact_set_name.json
```

Factsets are named based on their filename, i.e. `myfactset` in `onceover.yaml` refers `spec/factsets/myfactset.json`

#### Trusted Facts

You can add trusted facts to the factsets by creating a new section called trusted:

```json
{
  "name": "node.puppetlabs.net",
  "trusted": {
    "pp_role": "agent",
    "pp_datacenter": "puppet",
  },
  "values": {
    "aio_agent_build": "1.10.4",
    "aio_agent_version": "1.10.4",
    "architecture": "x86_64",
```

Notice that the `extensions` part is implied. The first fact in that example translates to `$trusted['extensions']['pp_role']` in Puppet code.

Alternatively, if you generated your factset using the PE client tools your trusted facts will be nested under the **values** hash. For example:

```json
{
  "name": "node.puppetlabs.net",
  "values": {
    "aio_agent_build": "1.10.4",
    "aio_agent_version": "1.10.4",
    "architecture": "x86_64",
    "trusted": {
      "extensions": {
        "pp_role": "agent",
        "pp_datacenter": "puppet"
      }
    }
```

In this case, you're all set and onceover will auto-magically pick those up for you.

**Note**: The top level `trusted` hash takes precidence over the `trusted[extensions]` hash nested under `values`. Meaning that if you have any specified at the top level, any nested ones will not be considered. So pick **ONE** method and stick with that.

#### Trusted Certname
**Note:** When testing with Puppet >= 4.3 the trusted facts hash will have the standard trusted fact keys (certname, domain, and hostname) populated based on the node name (as set with :node). 

To support the resolution of the trusted fact `certname` in auto-generated spec tests, onceover will set `:node` to the value of `trusted[certname]` where present in the source factset. 

For example: A spec test generated by the factset below would result in `:node` == `node.puppetlabs.net`.

```json
{
  "name": "node.puppetlabs.net",
  "values": {
    "aio_agent_build": "1.10.4",
    "aio_agent_version": "1.10.4",
    "architecture": "x86_64",
    "trusted": {
      "certname": "node.puppetlabs.net",
      "extensions": {
        "pp_role": "agent",
        "pp_datacenter": "puppet"
      }
    }
```

If `trusted[certname]` is absent, the value of `:node` will default to the FQDN of the host running onceover. For example:

```json
{
  "name": "node.puppetlabs.net",
  "values": {
    "aio_agent_build": "1.10.4",
    "aio_agent_version": "1.10.4",
    "architecture": "x86_64",
    "trusted": {
      "extensions": {
        "pp_role": "agent",
        "pp_datacenter": "puppet"
      }
    }
```

See the following rspec-puppet links for more information:
 - [Specifying the FQDN of the test node](https://github.com/puppetlabs/rspec-puppet#specifying-the-fqdn-of-the-test-node)
 - [Specifying trusted facts](https://github.com/puppetlabs/rspec-puppet#specifying-trusted-facts)

#### Trusted External Data

**Note:** This feature requires `rspec-puppet` >= 2.8.0.

You can add trusted external data to the factsets by creating a new section called trusted_external:

```json
{
  "name": "node.puppetlabs.net",
  "trusted_external": {
    "example_forager": {
      "globalRegion": "EMEA",
      "serverOwner": "John Doe"
    }
  },
  "values": {
    "aio_agent_build": "1.10.4",
    "aio_agent_version": "1.10.4",
    "architecture": "x86_64",
```

Notice that the `external` part is implied, though the foragers name will still need to be provided. The first fact in that example translates to `$trusted['external']['example_forager']['globalRegion']` in Puppet code.

Alternatively, if you generated your factset using the PE client tools your trusted external data will be nested under the **values** hash. For example:

```json
{
  "name": "node.puppetlabs.net",
  "values": {
    "aio_agent_build": "1.10.4",
    "aio_agent_version": "1.10.4",
    "architecture": "x86_64",
    "trusted": {
      "external": {
        "example_forager": {
          "globalRegion": "EMEA",
          "serverOwner": "John Doe"
        }
      }
    }
```

In this case, you're all set and onceover will auto-magically pick those up for you.

**Note**: The top level `trusted_external` hash takes precidence over the `trusted[external]` hash nested under `values`. Meaning that if you have any specified at the top level, any nested ones will not be considered. So pick **ONE** method and stick with that.

### Hiera

If you have hiera data inside your controlrepo (or somewhere else) `onceover` can be configured to use it.
It is however worth noting the `hiera.yaml` file that you currently use may not be applicable for testing right away.
For example; if you are using `hiera-eyaml` I recommend creating a `hiera.yaml` purely for testing that simply uses the `yaml` backend, meaning that you don't need to provide the private keys to the testing machines.

It is also worth noting that any hiera hierarchies that are based on custom facts will not work unless those facts are part of your factsets.
Trusted facts will also not work at all as the catalogs are being compiled without the node's certificate.
In these instances it may be worth creating a hierarchy level that simply includes dummy data for testing purposes in order to avoid hiera lookup errors.

### Puppetfile

Organisations often reference modules from their own git servers in the `Puppetfile`, like this:

```
mod "puppetlabs-apache",
  :git => "https://git.megacorp.com/pup/puppetlabs-apache.git",
  :tag => "v5.4.0"
```

Under the hood, `onceover` uses `r10k` to download the modules in your `Puppetfile`.
If you get errors downloading modules from `git`, its because `r10k`'s call to your underlying `git` command has failed.
`onceover` tells you the command that `r10k` tried to run, so if you get an error like this:

```
INFO     -> Updating module /Users/dylan/control-repo/.onceover/etc/puppetlabs/code/environments
/production/modules/apache
ERROR    -> Command exited with non-zero exit code:
Command: git --git-dir /Users/dylan/.r10k/git/ssh---git.megacorp.com-pup-puppetlabs_apache.git fetch origin --prune
Stderr:
ssh_askpass: exec(/usr/bin/ssh-askpass): No such file or directory
Host key verification failed.

fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
Exit code: 128
```

Then the approach to debug it would be to run the command that Onceover suggested:

```
git --git-dir /Users/dylan/.r10k/git/ssh---git.megacorp.com-pup-puppetlabs_apache.git fetch origin --prune
```

In this case, running the command interactively gives us a prompt to add the server to our `~/.ssh/known_hosts` file, which fixes the problem permanently:

```
$ git --git-dir /Users/dylan/.r10k/git/ssh---git.megacorp.com-pup-puppetlabs_apache.git fetch origin --prune
The authenticity of host 'git.megacorp.com (123.456.789.101)' can't be established.
...
Warning: Permanently added 'git.megacorp.com,123.456.789.101' (RSA) to the list of known hosts.
```

The other way to resolve this would have been to install the `ssh_askpass` program, but this can spam the screen with modal dialogs on some platforms.

#### r10k configuration

If you have custom r10k config that you want to use, place the `r10k.yaml` file in one of the following locations:

- `{repo root}/r10k.yaml`
- `{repo root}/spec/r10k.yaml`

A good use of this is [enabling multi threading](https://github.com/puppetlabs/r10k/blob/master/doc/dynamic-environments/configuration.mkd#pool_size) by creating the following in `r10k.yaml`:

```yaml
# spec/r10k.yaml
---
pool_size: 20
```

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

#### `hiera-eyaml`

If you are using the `hiera-eyaml` backend there are some modifications that you will need to make in order to ensure that things actually work. Remember that when onceover compiles catalogs it is actually using hiera with your config file to do the lookups on the host that is running the tests, meaning that the `hiera-eyaml` gem will need to be present (put it in your Gemfile), as will the keys in the correct location, otherwise hiera will fail to load them. *This is really not a great situation as you don't want to be distributing your private keys*

**Recommended Solution:** I recommend that if you are using `hiera-eyaml` (which you probably should be) that you do the following:

  1. Duplicate your `hiera.yaml` file so that there is a copy in the `spec/` directory
  1. Change the `datadir` setting as described above
  1. Remove the eyaml backend entirely and just use the base yaml backend. For hiera 5 this will look like:

  ```yaml
  ---
  version: 5
  defaults:
    datadir: "../data"
    data_hash: yaml_data
  ```

This means that for testing, hiera will just return the encrypted string for anything that is encrypted using eyaml. This usually isn't a problem for catalog compilation and will allow tests to pass.

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

[Resource collectors](https://docs.puppetlabs.com/puppet/latest/reference/lang_resources_advanced.html#amending-attributes-with-a-collector) are likely to come in handy here too. They allow you to override values of resources that match given criteria. This way we can override things for the sake of testing without having to change the code.

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
  4. Run Onceover again
  5. Create a pull request if all tests pass

### Overriding Onceover's Templates

Onceover uses templates to create a bunch of files in the `.onceover` directory, these templates can be modified if required. To do this create your own custom template with the same name os the original in the `spec/templates/` directory and it will be used in preference to the default template. e.g. `spec/templates/spec_helper.rb.erb`

### Accessing Onceover in a traditional RSpec test

If you would like to use `onceover.yaml` to manage which tests you want to run, but want more than just `it { should_compile }` tests to be run you can write you own as follows:

```ruby
# spec/classes/role_spec.rb
require 'spec_helper'
require 'onceover/controlrepo'
require 'helpers/shared_examples'

Onceover::Controlrepo.new.spec_tests do |class_name, node_name, facts, trusted_facts, trusted_external_data, pre_conditions|
  describe class_name do
    context "on #{node_name}" do
      let(:facts) { facts }
      let(:trusted_facts) { trusted_facts }
      let(:trusted_external_data) { trusted_external_data }
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

### Ruby Warnings

When running onceover with `--debug` you will see ruby warnings in your test output such as `warning: constant ::Fixnum is deprecated`. This is because when running without `--debug` onceover sets the `RUBYOPT` environment variable to `-W0` during the run. If you would like to run in debug mode but still want to suppress ruby warnings, simply run the following command before your tests:

```shell
export RUBYOPT='-W0'
```

It is also worth noting if you want to use `RUBYOPT` for some other reason when testing you will **need** to use `--debug` to stop it being clobbered by onceover.

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

  - @jessereynolds
  - @op-ct
  - @GeoffWilliams
  - @beergeek
  - @jairojunior
  - @natemccurdy
  - @aardvark
  - @Mandos
  - @Nekototori
  - @LMacchi
  - @tabakhase
  - @binford2k
  - @raphink
  - @tequeter
  - @alexjfisher
  - @smortex
  - @16c7x
  - @neomilium
  - @chlawren

