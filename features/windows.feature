@windows
Feature: Run onceover with windows 
  Onceover should allow to run rspec and acceptance test for all profvile and role classes
  or for any part of them. Use should set if he wants to see only summary of tests or full
  log info.

  Background:
    Given onceover executable

  Scenario: Run with common Windows code
    Given control repo "windows"
    When I run onceover command "run spec" with class "role::users"
    Then I should not see any errors

  Scenario: Run with common Windows code without workarounds
    Given existing control repo "windows"
    When I run onceover command "run spec --no_workarounds" with class "role::users"
    And test osfamily is not "windows"
    Then Onceover should exit 1

  Scenario: Compiling a windows role with groups that is valid should compile
    Given control repo "windows"
    When I run onceover command "run spec" with class "role::groups"
    Then I should not see any errors
  
  Scenario: Compiling a windows role with users that is valid should compile
    Given control repo "windows"
    When I run onceover command "run spec" with class "role::users"
    Then I should not see any errors
  
