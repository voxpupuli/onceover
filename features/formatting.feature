@formatting
Feature: Format errors nicely
  I would like Onceover to format errors nicely so that they are easily read

  Background:
    Given the OnceoverFormatter

  Scenario: Parse a missing class error
    When Puppet throws the error: "error during compilation: Evaluation Error: Error while evaluating a Function Call, Could not find class ::role::websevrer for server01.foo.com (line: 17, column: 1) on node server01.foo.com"
    Then the error should parse successfully
    And it should find 1 error
    And the parsed error should contain the following keys: text, line, column

  Scenario: Parse an incorrect parameter error
    When Puppet throws the error: "error during compilation: Evaluation Error: Error while evaluating a Resource Statement, Class[Docker]: has no parameter named 'package_name' (file: /some/path/tp/the/file/module/manifests/profile/docker.pp, line: 8, column: 1) on node server01.foo.com"
    Then the error should parse successfully
    And it should find 1 error
    And the parsed error should contain the following keys: text, file, line, column

  Scenario: Parse a duplication declaration error
    When Puppet throws the error: "error during compilation: Evaluation Error: Error while evaluating a Resource Statement, Duplicate declaration: Package[virtualenv] is already declared at (file: /some/path/tp/the/file/foo/manifests/profile/ti2.pp, line: 31); cannot redeclare (file: /some/path/tp/the/file/python/manifests/install.pp, line: 54) (file: /some/path/tp/the/file/python/manifests/install.pp, line: 54, column: 3) on node server01.foo.co"
    Then the error should parse successfully
    And it should find 2 errors
    And the parsed errors should contain the following keys: text, file, line, column

  Scenario: Parse a lookup failure error
    When Puppet throws the error: "error during compilation: Function lookup() did not find a value for the name 'archvsync::repositories' on node server01.foo.com"
    Then the error should parse successfully
    And it should find 1 errors
    And the parsed errors should contain the following keys: text
