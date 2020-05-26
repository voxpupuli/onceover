@factsets
Feature: Handle factsets properly
  Onceover should allow users to add their own factsets and should handle these well

  Background:
    Given onceover executable

  Scenario: Selecting existing factsets
    Given control repo "factsets"
    When I run onceover command "init"
    Then the config should contain "centos_with_env"

  # This needs to be tested because an environment fact, if not handled, makes
  # compilation fail becaiuse it breaks all of the workarounds that have been
  # put in place within rspec-puppet for the environment
  Scenario: Run with a factsent containing an environment facts
    Given existing control repo "factsets"
    When I run onceover command "run spec"
    Then I should not see any errors

  Scenario: Using trusted facts
    Given existing control repo "factsets"
    When I run onceover command "run spec"
    Then I should not see any errors
