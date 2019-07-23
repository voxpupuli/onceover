@acceptance
Feature: Run onceover's acceptance tests
  Onceover should be able to run acceptance tests as well as spec tests

  Background:
    Given onceover executable

  Scenario: Run spec tests when configured with acceptance tests also
    Given control repo "acceptance"
    When I run onceover command "run spec"
    Then I should not see any errors
    And I should see message pattern "3 examples"

