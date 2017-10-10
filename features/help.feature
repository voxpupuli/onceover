Feature: Get help about Onceover's features, commands and commands' parameters
  I would like to use executable file to run Onceover and read help

  Background:
    Given onceover executable

  Scenario: Show main options with executable wihtout parameters
    When I run onceover command ""
    Then I see help for commands: "help, init, run, show, update"

  Scenario: Show main help with "help" command
    When I run onceover command "help"
    Then I see help for commands: "help, init, run, show, update"

