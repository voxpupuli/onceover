Feature: Show the state of things
  For a correct controlrepo I would like to see details of the Puppetfile and
  the things that have been detected by onceover in the controlrepo.

  Background:
    Given onceover executable

  Scenario: Show info for basic repo
    Given initialized control repo "basic"
    When I run onceover command "show repo"
    Then I should not see any errors

  Scenario: Detect roles and profiles
    Given initialized control repo "basic"
    When I run onceover command "show repo"
    Then I should not see any errors
    And I should see message pattern "roles.*role::database_server"
    And I should see message pattern "roles.*role::webserver"
    And I should see message pattern "roles.*role::example"
    And I should see message pattern "profiles.*profile::example"
    And I should see message pattern "profiles.*profile::base"

  Scenario: Detect modules
    Given initialized control repo "basic"
    When I run onceover command "show puppetfile"
    Then I should not see any errors
    And I should see message pattern "puppetlabs-stdlib\s+\|\s+4\.11\.0"
    And I should see message pattern "apache\s+\|\s+N/A"
