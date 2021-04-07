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
  # compilation fail because it breaks all of the workarounds that have been
  # put in place within rspec-puppet for the environment
  @puppet6
  Scenario: Run with a factset containing an environment facts
    Given existing control repo "factsets"
    When I run onceover command "run spec" with class "role::example"
    Then I should not see any errors

  @puppet6
  Scenario: Run trusted_extensions tests on nodes where pp_datacenter is PDK
    Given existing control repo "factsets"
    When I run onceover command "run spec" with class "role::trusted_extensions" on nodes "centos7_trusted_extensions_top,centos7_trusted_extensions_nested"
    Then I should not see any errors

  # Spec tests should only pass on the centos7_trusted_extensions_top and
  #   centos7_trusted_extensions_nested factsets. The rest should fail
  @puppet6
  Scenario: Run trusted_extensions tests on nodes where pp_datacenter is not set
    Given existing control repo "factsets"
    When I run onceover command "run spec" with class "role::trusted_extensions"
    Then I should see error with message pattern "Evaluation Error: Error while evaluating a Function Call, pp_datacenter is not set to PDX"

  @puppet6
  Scenario: Run trusted_external tests on nodes where $trusted['external']['example']['foo'] is set to 'bar'
    Given existing control repo "factsets"
    When I run onceover command "run spec" with class "role::trusted_external" on nodes "centos7_trusted_external_top,centos7_trusted_external_nested"
    Then I should not see any errors

  # Spec tests should only pass on the centos7_trusted_externalq_top and
  #   centos7_trusted_external_nested factsets. The rest should fail
  @puppet6
  Scenario: Run trusted_external tests on nodes where $trusted['external'] is not specified
    Given existing control repo "factsets"
    When I run onceover command "run spec" with class "role::trusted_external"
    Then I should see error with message pattern "Evaluation Error: Operator \'\[\]\' is not applicable to an Undef Value."
