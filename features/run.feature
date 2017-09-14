Feature: Run rspec and acceptance test suits
  Onceover should allow to run rspec and acceptance test for all profvile and role classes
  or for any part of them. Use should set if he wants to see only summary of tests or full
  log info.

  Background:
    Given onceover executable

 Scenario: Run correct spec tests
    Given initialized control repo "controlrepo_basic"
    When I run onceover command "run spec"
    Then I should not see any errors

 Scenario: Run spec tests with misspelled module in Puppetfile
    Given initialized control repo "controlrepo_basic"
    And in Puppetfile is misspelled module's name
    When I run onceover command "run spec"
    Then I should see error with message pattern "The module acma-not_exists does not exists"

