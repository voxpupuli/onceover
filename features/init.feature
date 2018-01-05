Feature: Initialize Onceover application
  For correct control repo I would like to generate all folders and files needed
  by Onceover. For incorrect control repo I would like to get information why
  I can not initialize application.

  Background:
    Given onceover executable

  Scenario: Initialize basic repo
    Given control repo "basic"
    When I run onceover command "init"
    Then I should not see any errors
    And I should see generated all necessary files and folders

  Scenario: Initialize repo with missing environment.conf file
    Given control repo "basic" without "environment.conf"
    When I run onceover command "init"
    Then I should see error with message pattern "No such file or directory.*environment.conf"
