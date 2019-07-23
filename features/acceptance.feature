@acceptance
Feature: Run onceover's acceptance tests
  Onceover should be able to run acceptance tests as well as spec tests

  Background:
    Given onceover executable

  Scenario: Run spec tests with an acceptance-only node
    Given control repo "acceptance"
    When I run onceover command "run spec --tags all"
    Then I should see message pattern "Could not find factset for node: Name-Doesnt-Map"
    And Onceover should exit 1

  Scenario: Run acceptance tests with an spec-only node
    Given control repo "acceptance"
    When I run onceover command "run accptance --tags all"
    Then I should see message pattern "SOME GOOD MESSAGE ABOUT NOT HAVING A PROVISIONER"
    And Onceover should exit 1

  Scenario: Run spec tests when configured with acceptance tests also
    Given control repo "acceptance"
    When I run onceover command "run spec --tags spec"
    Then I should not see any errors
    And I should see message pattern "role::example"

  Scenario: Run accpetance tests
    Given control repo "acceptance"
    When I run onceover command "run acceptance --tags acceptance"
    Then I should not see any errors
    And I should see message pattern "role::example"

