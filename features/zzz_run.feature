@run
Feature: Run rspec and acceptance test suites
  Onceover should allow to run rspec and acceptance test for all profile and role classes
  or for any part of them. Use should set if he wants to see only summary of tests or full
  log info.

  Background:
    Given onceover executable

  Scenario: Run without a Puppetfile
    Given initialized control repo "minimal"
    When I run onceover command "run spec"
    Then I should not see any errors

  Scenario: Run correct spec tests
    Given initialized control repo "basic"
    When I run onceover command "run spec"
    Then I should not see any errors

  Scenario: Run correct spec tests in parallel
    Given initialized control repo "basic"
    When I run onceover command "run spec --parallel"
    Then I should not see any errors

  Scenario: Using regexes to define tests
    Given initialized control repo "caching"
    When I run onceover command "run spec"
    Then I should see message pattern "apache::params"

  Scenario: Checking that r10k config works
    Given initialized control repo "caching"
    When I run onceover command "run spec --debug"
    Then I should see message pattern "r10k.yaml"

  Scenario: Run spec tests with misspelled module in Puppetfile
    Given initialized control repo "basic"
    And in Puppetfile is misspelled module's name
    When I run onceover command "run spec"
    Then I should see error with message pattern "The module acme-not_exists does not exist"

  @skip_on_windows
  Scenario: Force overwrite local modifications
    Given initialized control repo "basic"
    When I run onceover command "run spec"
    And I make local modifications
    And I run onceover command "run spec --force"
    Then I should see message pattern "Overwriting local modifications"

  Scenario: When using an alternate manifests directory
    Given initialized control repo "basic"
    When I run onceover command "run spec --manifest manifests_alternate"
    Then I should see error with message pattern "Using alternate site.pp"

  Scenario: Check that control_branch functionality works
    Given initialized control repo "control_branch"
    When I run onceover command "run spec"
    Then the temporary Puppetfile should contain the git branch

  Scenario: Mocking functions should work and return the correct data types
    Given control repo "function_mocking"
    When I run onceover command "run spec" with class "role::test_data_return"
    Then I should not see any errors

  Scenario: Mocking functions that use the new :: pathing
    Given control repo "function_mocking"
    When I run onceover command "run spec" with class "role::test_new_functions"
    Then I should not see any errors

  Scenario: Running tests that fail to compile
    Given control repo "function_mocking"
    When I run onceover command "run spec" with class "role::fail"
    Then I should see message pattern "failed"
    And Onceover should exit 1

  Scenario: Run with a custom Puppetfile
    Given initialized control repo "custom_puppetfile"
    When I run onceover command "run spec" with --puppetfile Puppetfile.custom
    Then Puppetfile.custom should be copied to Puppetfile
    And I should see message pattern "Using Puppetfile .*Puppetfile"
    And I should see message pattern ".*extlib"

  Scenario: Testing that --tags works with native rspec tags
    Given control repo "puppet_controlrepo"
    When I run onceover command "run spec --tags syntax"
    Then I should not see any errors
    And I should see message pattern "When checking Puppet syntax"
    And I should not see message pattern "role::"

  # This test is a full test using my controlrepo. It should remain at the end because it takes ages
  Scenario: Run advanced spec tests
    Given control repo "puppet_controlrepo"
    When I run onceover command "run spec -p --force"
    Then I should not see any errors
