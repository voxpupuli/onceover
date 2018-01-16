@cache
Feature: Create and maintain a .onceover cache
  Onceover should be able to cache things in the .onceover directory for speed
  increases and debugging of external modules. This cache should remain
  up-to-date and should exactly mirror what would be created on the Puppet
  master.

  Background:
    Given onceover executable

  Scenario: Creating a cache
    Given control repo "caching"
    When I run onceover command "run spec"
    Then the cache should exist
    And the cache should contain all controlrepo files

  Scenario: Creating a new file
    Given control repo "caching"
    When I create a file "example.txt"
    And I run onceover command "run spec"
    Then "example.txt" should be cached correctly

  Scenario: Deleting a file
    Given control repo "caching"
    When I delete a file "deleteme.txt"
    And I run onceover command "run spec"
    Then "deleteme.txt" should be deleted from the cache

  Scenario: Caching hidden files
    Given control repo "caching"
    When I create a file ".hidden/.hiddenfile"
    And I run onceover command "run spec"
    Then ".hidden/.hiddenfile" should be cached correctly

  Scenario: Renaming a role
    Given control repo "caching"
    When I run onceover command "run spec"
    Then I rename the class "role::webserver" to "role::appserver"
    And I run onceover command "run spec"
    Then I should see error with message pattern "Could not find class ::role::webserver"
    And "site/role/manifests/webserver.pp" should be deleted from the cache
    And "site/role/manifests/appserver.pp" should be cached correctly
