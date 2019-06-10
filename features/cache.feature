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

  Scenario: Runnone onnceover in the caching repo
    Given control repo "caching"
    When I run onceover command "run spec --classes role::webserver"
    Then I should not see any errors

  Scenario: Creating a new file
    Given existing control repo "caching"
    When I create a file "example.txt"
    And I run onceover command "run spec"
    Then "example.txt" should be cached correctly

  Scenario: Deleting a file
    Given existing control repo "caching"
    When I delete a file "deleteme.txt"
    And I run onceover command "run spec"
    Then "deleteme.txt" should be deleted from the cache

  Scenario: Caching hidden files
    Given existing control repo "caching"
    When I create a file ".hidden/.hiddenfile"
    And I run onceover command "run spec"
    Then ".hidden/.hiddenfile" should be cached correctly
