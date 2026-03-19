@vendored @puppet6
Feature: Automatically resolve modules vendored with puppet-agent package
  Onceover should optionally attempt to resolve these vendored modules so that
  users do not need to maintain these in their Puppetfile's unless they have a reason
  to do so

  Background:
    Given onceover executable

  Scenario: Auto resolve disabled and Puppetfile empty
    Given initialized control repo "vendored"
    When I run onceover command "run spec" with class "role::cron"
    Then I should see error with message pattern "Evaluation Error: Error while evaluating a Resource Statement, Unknown resource type: 'cron'"

  Scenario: Auto resolve enabled and Puppetfile empty
    Given existing control repo "vendored"
    When I run onceover command "run spec --auto_vendored=true" with class "role::cron"
    Then the temporary Puppetfile should contain /mod 'puppetlabs-cron_core',\n.*git: 'https://github.com/openvoxproject\/puppetlabs-cron_core.git',\n.*ref: 'refs\/tags\/.*'/
    And I should not see any errors

  Scenario: Auto resolve enabled and cron_core specified in Puppetfile
    Given existing control repo "vendored"
    When I run onceover command "run spec --auto_vendored=true" with --puppetfile Puppetfile.cron
    Then I should see message pattern "cron_core found in Puppetfile. Using the specified version"
    Then the temporary Puppetfile should contain /mod 'puppetlabs\/cron_core'/
    And I should not see any errors

