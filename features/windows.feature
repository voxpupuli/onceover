@windows
Feature: Run onceover with windows 
  Onceover should allow to run rspec and acceptance test for all profvile and role classes
  or for any part of them. Use should set if he wants to see only summary of tests or full
  log info.

  Background:
    Given onceover executable

  Scenario: Run with common Windows code
    Given initialized control repo "windows"
    When I run onceover command "run spec"
    Then I should not see any errors

