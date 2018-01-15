@cache
Feature: Create and maintain a .onceover cache
  Onceover should be able to cache things in the .onceover directory for speed
  increases and debugging of external modules. This cache should remain
  up-to-date and should exactly mirror what would be created on the Puppet
  master.

  Background:
    Given onceover executable

  Scenario: Creating a cache
    Given initialized control repo "basic"
    When I run onceover command "run spec"
    Then the cache should exist
    And the cache should contain all controlrepo files

  Scenario: Creating a new file
    Given initialized control repo "basic"
    When I create a file "example.txt"
    And I run onceover command "run spec"
    Then "example.txt" should be cached correctly

  Scenario: Deleting a file
    Given initialized control repo "basic"
    When I delete a file "example.txt"
    And I run onceover command "run spec"
    Then "example.txt" should be deleted from the cache

  Scenario: Caching hidden files
    Given initialized control repo "basic"
    When I create a file ".hidden/.hiddenfile"
    And I run onceover command "run spec"
    Then ".hidden/.hiddenfile" should be cached correctly
