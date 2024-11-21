# Changelog

## [4.0.0](https://github.com/voxpupuli/onceover/tree/4.0.0) (2024-11-21)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.22.0...4.0.0)

**Breaking changes:**

- Require Ruby 2.7 & rubocop: Use voxpupuli-rubocop [\#342](https://github.com/voxpupuli/onceover/pull/342) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- rubocop: autofix [\#343](https://github.com/voxpupuli/onceover/pull/343) ([bastelfreak](https://github.com/bastelfreak))
- Add support to create symlinks [\#337](https://github.com/voxpupuli/onceover/pull/337) ([pkazi](https://github.com/pkazi))
- Add support for downloading \*\_core modules [\#335](https://github.com/voxpupuli/onceover/pull/335) ([garrettrowell](https://github.com/garrettrowell))

**Fixed bugs:**

- add rexml gem to fix chocolatey tests [\#339](https://github.com/voxpupuli/onceover/pull/339) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- CI: Apply Vox Pupuli best practices [\#341](https://github.com/voxpupuli/onceover/pull/341) ([bastelfreak](https://github.com/bastelfreak))
- dependabot: check for github actions and bundler [\#338](https://github.com/voxpupuli/onceover/pull/338) ([bastelfreak](https://github.com/bastelfreak))
- Adapt to Voxpupuli [\#336](https://github.com/voxpupuli/onceover/pull/336) ([rwaffen](https://github.com/rwaffen))
- \(maint\) - fix rubocop [\#334](https://github.com/voxpupuli/onceover/pull/334) ([garrettrowell](https://github.com/garrettrowell))

## [v3.22.0](https://github.com/voxpupuli/onceover/tree/v3.22.0) (2024-03-16)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.21.0...v3.22.0)

**Closed issues:**

- Trusted certname uses local trusted certname [\#289](https://github.com/voxpupuli/onceover/issues/289)

**Merged pull requests:**

- Ruby updates [\#332](https://github.com/voxpupuli/onceover/pull/332) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Allow resolution of trusted\[certname\] from factset rather than localhost [\#327](https://github.com/voxpupuli/onceover/pull/327) ([chambersmp](https://github.com/chambersmp))

## [v3.21.0](https://github.com/voxpupuli/onceover/tree/v3.21.0) (2023-06-17)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.20.0...v3.21.0)

**Closed issues:**

- Onceover generated spec directory copies empty files [\#320](https://github.com/voxpupuli/onceover/issues/320)
- Support Ruby 3 [\#316](https://github.com/voxpupuli/onceover/issues/316)
- does node\_groups key accept regular expressions [\#312](https://github.com/voxpupuli/onceover/issues/312)
- Error uninitialized constant RSpec::Puppet::Win32::Registry::Error running on linux env [\#287](https://github.com/voxpupuli/onceover/issues/287)

**Merged pull requests:**

- Onceover show Puppetfile - Add versionomy support for DSC module version format  [\#328](https://github.com/voxpupuli/onceover/pull/328) ([chambersmp](https://github.com/chambersmp))
- Fix onceover with modern Ruby [\#326](https://github.com/voxpupuli/onceover/pull/326) ([smortex](https://github.com/smortex))
- Add `onceover run spec --fail_fast` option [\#318](https://github.com/voxpupuli/onceover/pull/318) ([neomilium](https://github.com/neomilium))
- Fixed naming [\#314](https://github.com/voxpupuli/onceover/pull/314) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Fix typo [\#313](https://github.com/voxpupuli/onceover/pull/313) ([DavidS](https://github.com/DavidS))

## [v3.20.0](https://github.com/voxpupuli/onceover/tree/v3.20.0) (2021-04-07)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.19.2...v3.20.0)

**Merged pull requests:**

- Improve handling of trusted fact hash [\#309](https://github.com/voxpupuli/onceover/pull/309) ([garrettrowell](https://github.com/garrettrowell))

## [v3.19.2](https://github.com/voxpupuli/onceover/tree/v3.19.2) (2021-03-17)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.19.1...v3.19.2)

**Fixed bugs:**

- Facter changes break Onceover [\#307](https://github.com/voxpupuli/onceover/issues/307)

**Closed issues:**

- According to README, default value for `manifest` option is nil [\#292](https://github.com/voxpupuli/onceover/issues/292)

**Merged pull requests:**

- Adapted for Facter 4 factsets [\#308](https://github.com/voxpupuli/onceover/pull/308) ([genebean](https://github.com/genebean))

## [v3.19.1](https://github.com/voxpupuli/onceover/tree/v3.19.1) (2021-01-26)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.19.0...v3.19.1)

**Closed issues:**

- Could not autoload puppet/provider/acl/windows: cannot load such file -- win32/security [\#300](https://github.com/voxpupuli/onceover/issues/300)
- No such file or directory error when running on Windows [\#299](https://github.com/voxpupuli/onceover/issues/299)
- Facter 4 gem breaks things [\#258](https://github.com/voxpupuli/onceover/issues/258)

**Merged pull requests:**

- Gem and testing cleanup [\#303](https://github.com/voxpupuli/onceover/pull/303) ([genebean](https://github.com/genebean))
- Revert manifest setting default to nil [\#302](https://github.com/voxpupuli/onceover/pull/302) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Fix windows tests [\#301](https://github.com/voxpupuli/onceover/pull/301) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Add factsets for recent CentOS, Debian, & Ubuntu [\#297](https://github.com/voxpupuli/onceover/pull/297) ([djschaap](https://github.com/djschaap))
- Move to GitHub Actions for testing [\#296](https://github.com/voxpupuli/onceover/pull/296) ([genebean](https://github.com/genebean))
- Allow Facter 4 [\#294](https://github.com/voxpupuli/onceover/pull/294) ([genebean](https://github.com/genebean))

## [v3.19.0](https://github.com/voxpupuli/onceover/tree/v3.19.0) (2020-11-10)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.18.1...v3.19.0)

**Fixed bugs:**

- control\_branch support broken [\#282](https://github.com/voxpupuli/onceover/issues/282)

**Closed issues:**

- is there a way to execute only r10k step when running onceover [\#286](https://github.com/voxpupuli/onceover/issues/286)

**Merged pull requests:**

- Fix and document :manifest opt [\#290](https://github.com/voxpupuli/onceover/pull/290) ([op-ct](https://github.com/op-ct))
- Added chocolatey tests [\#288](https://github.com/voxpupuli/onceover/pull/288) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Fix `:control_branch` support [\#283](https://github.com/voxpupuli/onceover/pull/283) ([alexjfisher](https://github.com/alexjfisher))
- Add missing `require 'io/console'` [\#280](https://github.com/voxpupuli/onceover/pull/280) ([alexjfisher](https://github.com/alexjfisher))
- Readme improvements [\#275](https://github.com/voxpupuli/onceover/pull/275) ([neomilium](https://github.com/neomilium))

## [v3.18.1](https://github.com/voxpupuli/onceover/tree/v3.18.1) (2020-09-23)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.18.0...v3.18.1)

**Merged pull requests:**

- StandardError-patch-chrisl [\#281](https://github.com/voxpupuli/onceover/pull/281) ([chrislorro](https://github.com/chrislorro))

## [v3.18.0](https://github.com/voxpupuli/onceover/tree/v3.18.0) (2020-07-29)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.17.3...v3.18.0)

**Merged pull requests:**

- Support spec files selection before running tests [\#262](https://github.com/voxpupuli/onceover/pull/262) ([neomilium](https://github.com/neomilium))

## [v3.17.3](https://github.com/voxpupuli/onceover/tree/v3.17.3) (2020-07-17)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.17.2...v3.17.3)

**Merged pull requests:**

- Add choco\_install\_path fact to Windows factsets. [\#274](https://github.com/voxpupuli/onceover/pull/274) ([16c7x](https://github.com/16c7x))

## [v3.17.2](https://github.com/voxpupuli/onceover/tree/v3.17.2) (2020-07-08)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.17.1...v3.17.2)

**Fixed bugs:**

- show puppetfile subcommand table formatting is not aligned [\#182](https://github.com/voxpupuli/onceover/issues/182)

**Merged pull requests:**

- Improve show puppetfile [\#273](https://github.com/voxpupuli/onceover/pull/273) ([smortex](https://github.com/smortex))

## [v3.17.1](https://github.com/voxpupuli/onceover/tree/v3.17.1) (2020-07-01)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.17.0...v3.17.1)

**Fixed bugs:**

- undefined method name\_to\_principal when using DSC [\#269](https://github.com/voxpupuli/onceover/issues/269)

**Merged pull requests:**

- More Windows mocking!!! [\#272](https://github.com/voxpupuli/onceover/pull/272) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Renamed role [\#271](https://github.com/voxpupuli/onceover/pull/271) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Acl [\#268](https://github.com/voxpupuli/onceover/pull/268) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.17.0](https://github.com/voxpupuli/onceover/tree/v3.17.0) (2020-05-04)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.16.0...v3.17.0)

**Closed issues:**

- FYI - speedup `r10k puppetfile install` with g10k [\#234](https://github.com/voxpupuli/onceover/issues/234)

**Merged pull requests:**

- new factset: ubuntu 18.04 64 bit [\#264](https://github.com/voxpupuli/onceover/pull/264) ([GeoffWilliams](https://github.com/GeoffWilliams))
- \[docs\] Document r10k and git [\#263](https://github.com/voxpupuli/onceover/pull/263) ([GeoffWilliams](https://github.com/GeoffWilliams))
- Fixed controlrepo reference \(Fixes \#244\) [\#253](https://github.com/voxpupuli/onceover/pull/253) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.16.0](https://github.com/voxpupuli/onceover/tree/v3.16.0) (2020-04-21)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.15.2...v3.16.0)

**Closed issues:**

- How to only run onceover tests but not other rspec tests? [\#261](https://github.com/voxpupuli/onceover/issues/261)
- "Unknown resource type" for some puppet built-in resources [\#260](https://github.com/voxpupuli/onceover/issues/260)

**Merged pull requests:**

- Added support for r10k config files [\#226](https://github.com/voxpupuli/onceover/pull/226) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.15.2](https://github.com/voxpupuli/onceover/tree/v3.15.2) (2020-03-20)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.15.1...v3.15.2)

**Merged pull requests:**

- Pin to pre-facter 4 [\#259](https://github.com/voxpupuli/onceover/pull/259) ([genebean](https://github.com/genebean))

## [v3.15.1](https://github.com/voxpupuli/onceover/tree/v3.15.1) (2020-03-10)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.15.0...v3.15.1)

**Closed issues:**

- NoMethodError: undefined method `each' for :defaults:Symbol [\#255](https://github.com/voxpupuli/onceover/issues/255)
- \[DOC\] errant reference to controlrepo gem [\#244](https://github.com/voxpupuli/onceover/issues/244)

**Merged pull requests:**

- Fix compatibility with newer versions of `cri` [\#256](https://github.com/voxpupuli/onceover/pull/256) ([alexjfisher](https://github.com/alexjfisher))

## [v3.15.0](https://github.com/voxpupuli/onceover/tree/v3.15.0) (2019-10-19)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.14.1...v3.15.0)

**Closed issues:**

- Remove Litmus and use Bolt directly [\#239](https://github.com/voxpupuli/onceover/issues/239)
- Allow creation/destruction of litmus nodes [\#237](https://github.com/voxpupuli/onceover/issues/237)
- Implement less-than-MVP acceptance testing functionality [\#220](https://github.com/voxpupuli/onceover/issues/220)
- Move from mocha to rspec-mocks [\#210](https://github.com/voxpupuli/onceover/issues/210)

**Merged pull requests:**

- Move from mocha to rspec-mocks [\#252](https://github.com/voxpupuli/onceover/pull/252) ([op-ct](https://github.com/op-ct))

## [v3.14.1](https://github.com/voxpupuli/onceover/tree/v3.14.1) (2019-06-19)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.14.0...v3.14.1)

**Merged pull requests:**

- Added handling of bad execs [\#236](https://github.com/voxpupuli/onceover/pull/236) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.14.0](https://github.com/voxpupuli/onceover/tree/v3.14.0) (2019-06-19)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.13.4...v3.14.0)

**Implemented enhancements:**

- Properly test on windows [\#46](https://github.com/voxpupuli/onceover/issues/46)

**Merged pull requests:**

- Moved from 'json' to 'multi\_json' [\#235](https://github.com/voxpupuli/onceover/pull/235) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.13.4](https://github.com/voxpupuli/onceover/tree/v3.13.4) (2019-06-12)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.13.3...v3.13.4)

**Fixed bugs:**

- New formatting doesn't expose factset [\#231](https://github.com/voxpupuli/onceover/issues/231)

**Merged pull requests:**

- Formatter factset [\#232](https://github.com/voxpupuli/onceover/pull/232) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.13.3](https://github.com/voxpupuli/onceover/tree/v3.13.3) (2019-06-11)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.13.2...v3.13.3)

**Fixed bugs:**

- precondition pp files not escaped correctly when put into rspec-puppet precondition heredoc [\#224](https://github.com/voxpupuli/onceover/issues/224)
- A Puppetfile should not be a requirement [\#223](https://github.com/voxpupuli/onceover/issues/223)

**Closed issues:**

- environment set in factset causes problems [\#227](https://github.com/voxpupuli/onceover/issues/227)

**Merged pull requests:**

- Fixed escaping in pre\_conditions [\#230](https://github.com/voxpupuli/onceover/pull/230) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Added handling for environment fact [\#229](https://github.com/voxpupuli/onceover/pull/229) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Added the ability to handle missing Puppetfile [\#228](https://github.com/voxpupuli/onceover/pull/228) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Add `vendor` to `excluded_dirs` [\#225](https://github.com/voxpupuli/onceover/pull/225) ([alexjfisher](https://github.com/alexjfisher))

## [v3.13.2](https://github.com/voxpupuli/onceover/tree/v3.13.2) (2019-06-04)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.13.1...v3.13.2)

## [v3.13.1](https://github.com/voxpupuli/onceover/tree/v3.13.1) (2019-06-04)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.13.0...v3.13.1)

**Merged pull requests:**

- Added ability to hand `=` in environment.conf and worked around CRI issue [\#222](https://github.com/voxpupuli/onceover/pull/222) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.13.0](https://github.com/voxpupuli/onceover/tree/v3.13.0) (2019-05-08)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.12.5...v3.13.0)

**Implemented enhancements:**

- Create appveyor tests [\#195](https://github.com/voxpupuli/onceover/issues/195)

**Merged pull requests:**

- New factsets [\#219](https://github.com/voxpupuli/onceover/pull/219) ([GeoffWilliams](https://github.com/GeoffWilliams))

## [v3.12.5](https://github.com/voxpupuli/onceover/tree/v3.12.5) (2019-04-09)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.12.4...v3.12.5)

**Merged pull requests:**

- \(\#215\) Simplfy and speed up cache building [\#216](https://github.com/voxpupuli/onceover/pull/216) ([GeoffWilliams](https://github.com/GeoffWilliams))
- Added appveyor config [\#214](https://github.com/voxpupuli/onceover/pull/214) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.12.4](https://github.com/voxpupuli/onceover/tree/v3.12.4) (2019-04-03)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.12.3...v3.12.4)

**Closed issues:**

- Bundler errors when running bundler \>2 [\#212](https://github.com/voxpupuli/onceover/issues/212)
- Unable to install onceover gem on windows due to symlink in r10k [\#204](https://github.com/voxpupuli/onceover/issues/204)

**Merged pull requests:**

- Fixed bundler error [\#213](https://github.com/voxpupuli/onceover/pull/213) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.12.3](https://github.com/voxpupuli/onceover/tree/v3.12.3) (2019-03-27)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.12.2...v3.12.3)

**Merged pull requests:**

- Added handling of ruby errors [\#209](https://github.com/voxpupuli/onceover/pull/209) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.12.2](https://github.com/voxpupuli/onceover/tree/v3.12.2) (2019-03-21)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.12.1...v3.12.2)

**Closed issues:**

- \#\<ArgumentError: invalid byte sequence in US-ASCII\> [\#207](https://github.com/voxpupuli/onceover/issues/207)

**Merged pull requests:**

- Skip over invalid character errors parsing some puppet code [\#208](https://github.com/voxpupuli/onceover/pull/208) ([GeoffWilliams](https://github.com/GeoffWilliams))

## [v3.12.1](https://github.com/voxpupuli/onceover/tree/v3.12.1) (2019-03-17)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.12.0...v3.12.1)

**Merged pull requests:**

- Parallel formatting [\#206](https://github.com/voxpupuli/onceover/pull/206) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.12.0](https://github.com/voxpupuli/onceover/tree/v3.12.0) (2019-03-16)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.11.1...v3.12.0)

**Merged pull requests:**

- Improved Formatting [\#205](https://github.com/voxpupuli/onceover/pull/205) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Do not strip newline at the end of the Puppetfile [\#203](https://github.com/voxpupuli/onceover/pull/203) ([smortex](https://github.com/smortex))

## [v3.11.1](https://github.com/voxpupuli/onceover/tree/v3.11.1) (2019-02-26)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.11.0...v3.11.1)

**Merged pull requests:**

- Fix exit code [\#202](https://github.com/voxpupuli/onceover/pull/202) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.11.0](https://github.com/voxpupuli/onceover/tree/v3.11.0) (2019-02-26)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.10.2...v3.11.0)

**Merged pull requests:**

- Adding summarized output of failures [\#200](https://github.com/voxpupuli/onceover/pull/200) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.10.2](https://github.com/voxpupuli/onceover/tree/v3.10.2) (2019-02-05)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.10.1...v3.10.2)

## [v3.10.1](https://github.com/voxpupuli/onceover/tree/v3.10.1) (2019-02-05)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.10.0...v3.10.1)

**Fixed bugs:**

- Doubled up results in output of 'run spec' [\#180](https://github.com/voxpupuli/onceover/issues/180)

## [v3.10.0](https://github.com/voxpupuli/onceover/tree/v3.10.0) (2019-02-05)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.9.0...v3.10.0)

**Implemented enhancements:**

- `mock_with` deprecation warnings [\#174](https://github.com/voxpupuli/onceover/issues/174)
- .onceover directory sync problems [\#113](https://github.com/voxpupuli/onceover/issues/113)

**Fixed bugs:**

- Onceover seems to fail mocking functions that include `::` [\#197](https://github.com/voxpupuli/onceover/issues/197)

**Closed issues:**

- Onceover 3.9.0 character type issue [\#196](https://github.com/voxpupuli/onceover/issues/196)
- Remove acceptance testing from README [\#186](https://github.com/voxpupuli/onceover/issues/186)
- Code Coverage Reports [\#184](https://github.com/voxpupuli/onceover/issues/184)

**Merged pull requests:**

- Modify how function mocking works [\#198](https://github.com/voxpupuli/onceover/pull/198) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.9.0](https://github.com/voxpupuli/onceover/tree/v3.9.0) (2018-12-24)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.8.0...v3.9.0)

**Implemented enhancements:**

- \[feature\] hiera debugging/puppet lookup support [\#114](https://github.com/voxpupuli/onceover/issues/114)
- \[feature\] support for regenerating/updating tests [\#61](https://github.com/voxpupuli/onceover/issues/61)

**Fixed bugs:**

- File resource on Windows "File paths must be fully qualified, not 'c:/foo/bar' at ... " [\#59](https://github.com/voxpupuli/onceover/issues/59)

**Closed issues:**

- Run tests against puppet 5? [\#188](https://github.com/voxpupuli/onceover/issues/188)
- undefined method `on_supported_os` [\#175](https://github.com/voxpupuli/onceover/issues/175)
- Onceover run spec ignores node names in factsets [\#168](https://github.com/voxpupuli/onceover/issues/168)
- Onceover.yaml support for r10k credentials? [\#166](https://github.com/voxpupuli/onceover/issues/166)

**Merged pull requests:**

- Updated ruby versions and controlrepo [\#194](https://github.com/voxpupuli/onceover/pull/194) ([dylanratcliffe](https://github.com/dylanratcliffe))
- remove all mention of acceptance testing/beaker [\#193](https://github.com/voxpupuli/onceover/pull/193) ([GeoffWilliams](https://github.com/GeoffWilliams))
- \(\#86\) Support regex in R10K downloaded modules [\#192](https://github.com/voxpupuli/onceover/pull/192) ([GeoffWilliams](https://github.com/GeoffWilliams))
- factset for windows 10 [\#191](https://github.com/voxpupuli/onceover/pull/191) ([GeoffWilliams](https://github.com/GeoffWilliams))
- fix spelling: weather vs. whether [\#179](https://github.com/voxpupuli/onceover/pull/179) ([tequeter](https://github.com/tequeter))

## [v3.8.0](https://github.com/voxpupuli/onceover/tree/v3.8.0) (2018-09-05)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.7.0...v3.8.0)

**Implemented enhancements:**

- Update README.md [\#177](https://github.com/voxpupuli/onceover/pull/177) ([beergeek](https://github.com/beergeek))

**Closed issues:**

- Difficulty with Hiera-eyaml, Factsets, and Automatic Class Parameters [\#171](https://github.com/voxpupuli/onceover/issues/171)

**Merged pull requests:**

- show puppetfile: Add endorsement and superseded\_by [\#178](https://github.com/voxpupuli/onceover/pull/178) ([raphink](https://github.com/raphink))

## [v3.7.0](https://github.com/voxpupuli/onceover/tree/v3.7.0) (2018-05-15)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.6.2...v3.7.0)

**Merged pull requests:**

- Enabled trusted\_server\_facts [\#173](https://github.com/voxpupuli/onceover/pull/173) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.6.2](https://github.com/voxpupuli/onceover/tree/v3.6.2) (2018-05-13)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.6.1...v3.6.2)

**Merged pull requests:**

- Check Node/Classes hashes [\#172](https://github.com/voxpupuli/onceover/pull/172) ([beergeek](https://github.com/beergeek))
- \(GH-46\) Enable tests to be run on Windows [\#170](https://github.com/voxpupuli/onceover/pull/170) ([glennsarti](https://github.com/glennsarti))

## [v3.6.1](https://github.com/voxpupuli/onceover/tree/v3.6.1) (2018-04-05)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.6.0...v3.6.1)

**Fixed bugs:**

- Path error on run spec [\#97](https://github.com/voxpupuli/onceover/issues/97)

**Merged pull requests:**

- Allow loading of symbols [\#169](https://github.com/voxpupuli/onceover/pull/169) ([dylanratcliffe](https://github.com/dylanratcliffe))
- fix fixtures\_symlinks on Windows default tempdir [\#167](https://github.com/voxpupuli/onceover/pull/167) ([tabakhase](https://github.com/tabakhase))

## [v3.6.0](https://github.com/voxpupuli/onceover/tree/v3.6.0) (2018-03-27)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.5.2...v3.6.0)

**Implemented enhancements:**

- Add trusted facts support [\#151](https://github.com/voxpupuli/onceover/issues/151)

**Merged pull requests:**

- Add trusted facts support [\#163](https://github.com/voxpupuli/onceover/pull/163) ([LMacchi](https://github.com/LMacchi))

## [v3.5.2](https://github.com/voxpupuli/onceover/tree/v3.5.2) (2018-03-15)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.5.1...v3.5.2)

**Merged pull requests:**

- Skip copy of r10k modules directory. [\#162](https://github.com/voxpupuli/onceover/pull/162) ([mikkergimenez](https://github.com/mikkergimenez))

## [v3.5.1](https://github.com/voxpupuli/onceover/tree/v3.5.1) (2018-03-08)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.5.0...v3.5.1)

**Fixed bugs:**

- Mocked functions that return strings can cause errors [\#159](https://github.com/voxpupuli/onceover/issues/159)

**Closed issues:**

- Puppet gem v5.3.4 breaks spec tests [\#152](https://github.com/voxpupuli/onceover/issues/152)

**Merged pull requests:**

- Fix function mocking [\#160](https://github.com/voxpupuli/onceover/pull/160) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.5.0](https://github.com/voxpupuli/onceover/tree/v3.5.0) (2018-03-06)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.4.0...v3.5.0)

**Merged pull requests:**

- Added new force param [\#158](https://github.com/voxpupuli/onceover/pull/158) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Add functionality to allow custom templates in control repo, this all… [\#157](https://github.com/voxpupuli/onceover/pull/157) ([mikkergimenez](https://github.com/mikkergimenez))

## [v3.4.0](https://github.com/voxpupuli/onceover/tree/v3.4.0) (2018-02-27)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.3.3...v3.4.0)

**Merged pull requests:**

- Add before and after :each blocks [\#155](https://github.com/voxpupuli/onceover/pull/155) ([LMacchi](https://github.com/LMacchi))

## [v3.3.3](https://github.com/voxpupuli/onceover/tree/v3.3.3) (2018-02-26)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.3.2...v3.3.3)

**Implemented enhancements:**

- Tags should be implemented in native Rspec [\#83](https://github.com/voxpupuli/onceover/issues/83)

**Fixed bugs:**

- On non-initial spec runs, temporary control repo copied inside existing control repo rather than replacing it. [\#154](https://github.com/voxpupuli/onceover/issues/154)
- Autogenerated spec tests don't work for certain factsets [\#105](https://github.com/voxpupuli/onceover/issues/105)
- Trouble using traditional Rspec tests with factsets [\#81](https://github.com/voxpupuli/onceover/issues/81)

**Closed issues:**

- Puppet conflicts with semantic\_puppet [\#153](https://github.com/voxpupuli/onceover/issues/153)
- Puppet fails to validate valid Windows paths running on Linux [\#109](https://github.com/voxpupuli/onceover/issues/109)
- Version 3.2.2 does not work out of the box with puppet version \< 5.0 [\#108](https://github.com/voxpupuli/onceover/issues/108)
- Onceover::Controlrepo.facts.each do processing too many files [\#103](https://github.com/voxpupuli/onceover/issues/103)
- Puppet not reading hiera correctly when running with onceover [\#98](https://github.com/voxpupuli/onceover/issues/98)
- Permission denied when running on server where r10k has run as root [\#96](https://github.com/voxpupuli/onceover/issues/96)
- \[question\] Are you plan to implement support for Librarian Puppet? [\#80](https://github.com/voxpupuli/onceover/issues/80)
- Permission denied error on file [\#67](https://github.com/voxpupuli/onceover/issues/67)

**Merged pull requests:**

- Fixed caching regression [\#156](https://github.com/voxpupuli/onceover/pull/156) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Made the hiera section more readable [\#149](https://github.com/voxpupuli/onceover/pull/149) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.3.2](https://github.com/voxpupuli/onceover/tree/v3.3.2) (2018-01-15)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.3.1...v3.3.2)

**Fixed bugs:**

- Templated .file removed at some point [\#115](https://github.com/voxpupuli/onceover/issues/115)

**Closed issues:**

- Doesn't work out-of-the-box with Puppet's ruby [\#147](https://github.com/voxpupuli/onceover/issues/147)

**Merged pull requests:**

- Improve cache handling [\#148](https://github.com/voxpupuli/onceover/pull/148) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.3.1](https://github.com/voxpupuli/onceover/tree/v3.3.1) (2018-01-05)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.3.0...v3.3.1)

**Closed issues:**

- Issue Running onceover on Windows 10  [\#143](https://github.com/voxpupuli/onceover/issues/143)
- --skip\_r10k causes tests to run against stale copy of control-repo  [\#95](https://github.com/voxpupuli/onceover/issues/95)

**Merged pull requests:**

- Added workaround for windows delimiter [\#146](https://github.com/voxpupuli/onceover/pull/146) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.3.0](https://github.com/voxpupuli/onceover/tree/v3.3.0) (2018-01-05)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.2.8...v3.3.0)

**Merged pull requests:**

- Improve testing [\#145](https://github.com/voxpupuli/onceover/pull/145) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Add support for :control\_branch [\#144](https://github.com/voxpupuli/onceover/pull/144) ([Nekototori](https://github.com/Nekototori))

## [v3.2.8](https://github.com/voxpupuli/onceover/tree/v3.2.8) (2017-12-11)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.2.7...v3.2.8)

**Merged pull requests:**

- Acceptance tests \(ready to merge\) [\#139](https://github.com/voxpupuli/onceover/pull/139) ([mandos](https://github.com/mandos))
- Plugin documentation update [\#137](https://github.com/voxpupuli/onceover/pull/137) ([GeoffWilliams](https://github.com/GeoffWilliams))

## [v3.2.7](https://github.com/voxpupuli/onceover/tree/v3.2.7) (2017-10-04)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.2.6...v3.2.7)

**Closed issues:**

- --puppetfile option ignored in latest version [\#140](https://github.com/voxpupuli/onceover/issues/140)
- run spec should stop if all modules cannot be retrieved [\#54](https://github.com/voxpupuli/onceover/issues/54)

**Merged pull requests:**

- restore the --puppetfile option [\#141](https://github.com/voxpupuli/onceover/pull/141) ([GeoffWilliams](https://github.com/GeoffWilliams))
- Add acceptance tests for simple init scenario [\#138](https://github.com/voxpupuli/onceover/pull/138) ([mandos](https://github.com/mandos))
- Split rspec test to acceptance and unit tests [\#136](https://github.com/voxpupuli/onceover/pull/136) ([mandos](https://github.com/mandos))

## [v3.2.6](https://github.com/voxpupuli/onceover/tree/v3.2.6) (2017-09-12)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.2.5...v3.2.6)

**Closed issues:**

- Revert change to hiera load order [\#131](https://github.com/voxpupuli/onceover/issues/131)
- Onceover needs its own acceptance tests [\#116](https://github.com/voxpupuli/onceover/issues/116)

**Merged pull requests:**

- Add simple cucumber tests to check help command [\#134](https://github.com/voxpupuli/onceover/pull/134) ([mandos](https://github.com/mandos))
- Reverted order for hiera loading [\#132](https://github.com/voxpupuli/onceover/pull/132) ([dylanratcliffe](https://github.com/dylanratcliffe))
- only skip r10k when using --skip\_r10k [\#126](https://github.com/voxpupuli/onceover/pull/126) ([jessereynolds](https://github.com/jessereynolds))
- minimal refactor to aid readability [\#125](https://github.com/voxpupuli/onceover/pull/125) ([jessereynolds](https://github.com/jessereynolds))
- add submodule instructions [\#124](https://github.com/voxpupuli/onceover/pull/124) ([jessereynolds](https://github.com/jessereynolds))
- include ruby 2.4.0 in travis tests [\#123](https://github.com/voxpupuli/onceover/pull/123) ([jessereynolds](https://github.com/jessereynolds))

## [v3.2.5](https://github.com/voxpupuli/onceover/tree/v3.2.5) (2017-08-29)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.2.4...v3.2.5)

**Closed issues:**

- private method `local_variables` [\#121](https://github.com/voxpupuli/onceover/issues/121)
- Onceover does not generate nodesets [\#120](https://github.com/voxpupuli/onceover/issues/120)

**Merged pull requests:**

- Fix Issue 121 [\#122](https://github.com/voxpupuli/onceover/pull/122) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.2.4](https://github.com/voxpupuli/onceover/tree/v3.2.4) (2017-08-28)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.2.3...v3.2.4)

**Implemented enhancements:**

- \[feature\] run syntax checks on control repo files [\#62](https://github.com/voxpupuli/onceover/issues/62)

**Closed issues:**

- Deprecation warnings for hiera functions are breaking all tests when hiera functions used [\#107](https://github.com/voxpupuli/onceover/issues/107)
- Uninformative error when hiera.yaml is missing [\#104](https://github.com/voxpupuli/onceover/issues/104)

**Merged pull requests:**

- Merge mandos pr [\#119](https://github.com/voxpupuli/onceover/pull/119) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Add travis [\#118](https://github.com/voxpupuli/onceover/pull/118) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Syntax and style tests [\#117](https://github.com/voxpupuli/onceover/pull/117) ([jessereynolds](https://github.com/jessereynolds))

## [v3.2.3](https://github.com/voxpupuli/onceover/tree/v3.2.3) (2017-08-07)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.2.2...v3.2.3)

**Closed issues:**

- Error if hiera file is not present [\#111](https://github.com/voxpupuli/onceover/issues/111)
-  fact "hostname" already has the maximum number of resolutions allowed [\#106](https://github.com/voxpupuli/onceover/issues/106)

**Merged pull requests:**

- Control `opts` from `onceover.yaml` [\#110](https://github.com/voxpupuli/onceover/pull/110) ([op-ct](https://github.com/op-ct))

## [v3.2.2](https://github.com/voxpupuli/onceover/tree/v3.2.2) (2017-07-13)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.2.1...v3.2.2)

**Merged pull requests:**

- Added correct solution for \#100 [\#102](https://github.com/voxpupuli/onceover/pull/102) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.2.1](https://github.com/voxpupuli/onceover/tree/v3.2.1) (2017-07-13)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.2.0...v3.2.1)

**Implemented enhancements:**

- \[enhancemant\] built-in docker support [\#8](https://github.com/voxpupuli/onceover/issues/8)

**Closed issues:**

- Hiera 5 Support is bad [\#100](https://github.com/voxpupuli/onceover/issues/100)
- Onceover dies with a Hiera 5 [\#92](https://github.com/voxpupuli/onceover/issues/92)

**Merged pull requests:**

- \(\#100\) Changed hiera.yaml hierarchy [\#101](https://github.com/voxpupuli/onceover/pull/101) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Show puppet output [\#89](https://github.com/voxpupuli/onceover/pull/89) ([jessereynolds](https://github.com/jessereynolds))

## [v3.2.0](https://github.com/voxpupuli/onceover/tree/v3.2.0) (2017-03-13)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.1.1...v3.2.0)

**Implemented enhancements:**

- \[enhancement\] consider making a build without beaker [\#71](https://github.com/voxpupuli/onceover/issues/71)

**Merged pull requests:**

- Added plugin framework [\#88](https://github.com/voxpupuli/onceover/pull/88) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Deprecated Beaker and removed dependency [\#87](https://github.com/voxpupuli/onceover/pull/87) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Support for SLES 11/12 [\#85](https://github.com/voxpupuli/onceover/pull/85) ([GeoffWilliams](https://github.com/GeoffWilliams))

## [v3.1.1](https://github.com/voxpupuli/onceover/tree/v3.1.1) (2017-03-04)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.1.0...v3.1.1)

**Implemented enhancements:**

- Add `onceover show puppetfile` to README [\#66](https://github.com/voxpupuli/onceover/issues/66)
- Runs before the final run should discount outcome [\#51](https://github.com/voxpupuli/onceover/issues/51)

**Merged pull requests:**

- Feature/performance [\#82](https://github.com/voxpupuli/onceover/pull/82) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Fixed \#66 [\#79](https://github.com/voxpupuli/onceover/pull/79) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.1.0](https://github.com/voxpupuli/onceover/tree/v3.1.0) (2017-02-21)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.11...v3.1.0)

**Merged pull requests:**

- Feature/regex support [\#78](https://github.com/voxpupuli/onceover/pull/78) ([dylanratcliffe](https://github.com/dylanratcliffe))
- support for AIX 6.1 and 7.1 [\#76](https://github.com/voxpupuli/onceover/pull/76) ([GeoffWilliams](https://github.com/GeoffWilliams))
- Further Doco [\#74](https://github.com/voxpupuli/onceover/pull/74) ([beergeek](https://github.com/beergeek))

## [v3.0.11](https://github.com/voxpupuli/onceover/tree/v3.0.11) (2017-01-19)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.10...v3.0.11)

**Closed issues:**

- \[feature\] Puppetfile module substitution [\#72](https://github.com/voxpupuli/onceover/issues/72)
- test [\#70](https://github.com/voxpupuli/onceover/issues/70)

**Merged pull requests:**

- Fix small things [\#73](https://github.com/voxpupuli/onceover/pull/73) ([op-ct](https://github.com/op-ct))

## [v3.0.10](https://github.com/voxpupuli/onceover/tree/v3.0.10) (2016-12-14)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.9...v3.0.10)

**Merged pull requests:**

- Added the ability to toggle strict\_variables [\#69](https://github.com/voxpupuli/onceover/pull/69) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.0.9](https://github.com/voxpupuli/onceover/tree/v3.0.9) (2016-12-13)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.8...v3.0.9)

**Implemented enhancements:**

- Allow for integration of custom tests [\#12](https://github.com/voxpupuli/onceover/issues/12)

**Merged pull requests:**

- \[WIP\] Change HTTP requests to support http\(s\)\_proxy environment variables. [\#68](https://github.com/voxpupuli/onceover/pull/68) ([jairojunior](https://github.com/jairojunior))

## [v3.0.8](https://github.com/voxpupuli/onceover/tree/v3.0.8) (2016-10-15)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.7...v3.0.8)

**Closed issues:**

- groups should be able to be empty [\#55](https://github.com/voxpupuli/onceover/issues/55)

**Merged pull requests:**

- Fix a grammar issue [\#60](https://github.com/voxpupuli/onceover/pull/60) ([natemccurdy](https://github.com/natemccurdy))
- 54 skip r10k [\#57](https://github.com/voxpupuli/onceover/pull/57) ([jessereynolds](https://github.com/jessereynolds))
- 55 support empty groups [\#56](https://github.com/voxpupuli/onceover/pull/56) ([jessereynolds](https://github.com/jessereynolds))

## [v3.0.7](https://github.com/voxpupuli/onceover/tree/v3.0.7) (2016-05-30)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.6...v3.0.7)

**Implemented enhancements:**

- Should have the classname and factset name available [\#52](https://github.com/voxpupuli/onceover/issues/52)

**Closed issues:**

- Test Puppet 3/4 migration [\#47](https://github.com/voxpupuli/onceover/issues/47)

**Merged pull requests:**

- Issue 52 [\#53](https://github.com/voxpupuli/onceover/pull/53) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.0.6](https://github.com/voxpupuli/onceover/tree/v3.0.6) (2016-05-24)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.5...v3.0.6)

**Fixed bugs:**

- Copying bundler files results in error [\#49](https://github.com/voxpupuli/onceover/issues/49)

**Closed issues:**

- When manually calling controlrepo it is hard to respect config [\#44](https://github.com/voxpupuli/onceover/issues/44)

**Merged pull requests:**

- Issue 49 [\#50](https://github.com/voxpupuli/onceover/pull/50) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.0.5](https://github.com/voxpupuli/onceover/tree/v3.0.5) (2016-05-16)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.4...v3.0.5)

**Merged pull requests:**

- Issue 44 [\#45](https://github.com/voxpupuli/onceover/pull/45) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.0.4](https://github.com/voxpupuli/onceover/tree/v3.0.4) (2016-05-14)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.3...v3.0.4)

**Implemented enhancements:**

- unable to remove windows [\#41](https://github.com/voxpupuli/onceover/issues/41)

**Fixed bugs:**

- Change :: to \_\_ [\#40](https://github.com/voxpupuli/onceover/issues/40)
- specifying an alternate Puppetfile with --puppetfile doesn't seem to work [\#39](https://github.com/voxpupuli/onceover/issues/39)

## [v3.0.3](https://github.com/voxpupuli/onceover/tree/v3.0.3) (2016-05-06)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.2...v3.0.3)

**Merged pull requests:**

- Issue 40 [\#43](https://github.com/voxpupuli/onceover/pull/43) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Solaris factsets [\#42](https://github.com/voxpupuli/onceover/pull/42) ([jessereynolds](https://github.com/jessereynolds))

## [v3.0.2](https://github.com/voxpupuli/onceover/tree/v3.0.2) (2016-04-30)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.1...v3.0.2)

**Closed issues:**

- Code copying is broken [\#37](https://github.com/voxpupuli/onceover/issues/37)

**Merged pull requests:**

- Fixed \#37 [\#38](https://github.com/voxpupuli/onceover/pull/38) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Bundler hotfix [\#36](https://github.com/voxpupuli/onceover/pull/36) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v3.0.1](https://github.com/voxpupuli/onceover/tree/v3.0.1) (2016-04-28)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v3.0.0...v3.0.1)

## [v3.0.0](https://github.com/voxpupuli/onceover/tree/v3.0.0) (2016-04-28)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v2.0.10...v3.0.0)

**Implemented enhancements:**

- Change the name! [\#34](https://github.com/voxpupuli/onceover/issues/34)
- Add the ability to update Puppetfiles [\#30](https://github.com/voxpupuli/onceover/issues/30)
- Move Beaker ugliness from templates to gem [\#26](https://github.com/voxpupuli/onceover/issues/26)
- Allow filtering on nodes and classes too [\#25](https://github.com/voxpupuli/onceover/issues/25)
- Properly implement tags [\#24](https://github.com/voxpupuli/onceover/issues/24)
- Add function mocking [\#22](https://github.com/voxpupuli/onceover/issues/22)
- Add debugging [\#19](https://github.com/voxpupuli/onceover/issues/19)
- Fully test new CLI parameters [\#18](https://github.com/voxpupuli/onceover/issues/18)
- Create `controlrepo init` [\#17](https://github.com/voxpupuli/onceover/issues/17)
- Change temp dir to .controlrepo [\#16](https://github.com/voxpupuli/onceover/issues/16)
- Improve r10k deploy to remove re-download of modules [\#15](https://github.com/voxpupuli/onceover/issues/15)
- Create a CLI [\#14](https://github.com/voxpupuli/onceover/issues/14)
- Remove workaround for line prefix [\#13](https://github.com/voxpupuli/onceover/issues/13)

**Merged pull requests:**

- Issue 34 [\#35](https://github.com/voxpupuli/onceover/pull/35) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Fixed \#30 [\#33](https://github.com/voxpupuli/onceover/pull/33) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Fixed \#18 [\#32](https://github.com/voxpupuli/onceover/pull/32) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Issue 26 [\#31](https://github.com/voxpupuli/onceover/pull/31) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Added function mocking, fixes \#22 [\#29](https://github.com/voxpupuli/onceover/pull/29) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Added class and node filters, fixes \#25 [\#28](https://github.com/voxpupuli/onceover/pull/28) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Properly implemented tags. Fixes \#24 [\#27](https://github.com/voxpupuli/onceover/pull/27) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Added debugging, fixes \#19 [\#23](https://github.com/voxpupuli/onceover/pull/23) ([dylanratcliffe](https://github.com/dylanratcliffe))
- \(\#17\) Added modification of .gitignore to init [\#21](https://github.com/voxpupuli/onceover/pull/21) ([dylanratcliffe](https://github.com/dylanratcliffe))
- Create a CLI [\#20](https://github.com/voxpupuli/onceover/pull/20) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v2.0.10](https://github.com/voxpupuli/onceover/tree/v2.0.10) (2016-03-21)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v2.0.9...v2.0.10)

## [v2.0.9](https://github.com/voxpupuli/onceover/tree/v2.0.9) (2016-03-21)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v2.0.8...v2.0.9)

**Merged pull requests:**

- \(METHOD-570\) Added ability to add your own spec tests [\#11](https://github.com/voxpupuli/onceover/pull/11) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v2.0.8](https://github.com/voxpupuli/onceover/tree/v2.0.8) (2016-02-11)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v2.0.7...v2.0.8)

## [v2.0.7](https://github.com/voxpupuli/onceover/tree/v2.0.7) (2016-02-11)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v2.0.6...v2.0.7)

## [v2.0.6](https://github.com/voxpupuli/onceover/tree/v2.0.6) (2016-02-11)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v2.0.5...v2.0.6)

**Merged pull requests:**

- Method 569 [\#10](https://github.com/voxpupuli/onceover/pull/10) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v2.0.5](https://github.com/voxpupuli/onceover/tree/v2.0.5) (2016-02-08)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v2.0.4...v2.0.5)

## [v2.0.4](https://github.com/voxpupuli/onceover/tree/v2.0.4) (2016-02-08)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v2.0.3...v2.0.4)

**Implemented enhancements:**

- Phych::ParserError if controlrepo.yaml is missing [\#1](https://github.com/voxpupuli/onceover/issues/1)

**Closed issues:**

- \[bug\] ruby error if hiera.yaml is missing [\#7](https://github.com/voxpupuli/onceover/issues/7)
- \[enhancement\] ship a default nodeset [\#4](https://github.com/voxpupuli/onceover/issues/4)
- \[enhancement\] quickstart guide for the lazy/impatient \(me\) [\#3](https://github.com/voxpupuli/onceover/issues/3)
- \[enhancement\] ship with a default sets of facts [\#2](https://github.com/voxpupuli/onceover/issues/2)

**Merged pull requests:**

- Added support of the manifest setting [\#9](https://github.com/voxpupuli/onceover/pull/9) ([dylanratcliffe](https://github.com/dylanratcliffe))

## [v2.0.3](https://github.com/voxpupuli/onceover/tree/v2.0.3) (2015-11-20)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v2.0.2...v2.0.3)

## [v2.0.2](https://github.com/voxpupuli/onceover/tree/v2.0.2) (2015-11-20)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v2.0.1...v2.0.2)

**Closed issues:**

- \[bug\] ruby error when running controlrepo\_spec [\#5](https://github.com/voxpupuli/onceover/issues/5)

**Merged pull requests:**

- work without an r10k.yaml file [\#6](https://github.com/voxpupuli/onceover/pull/6) ([GeoffWilliams](https://github.com/GeoffWilliams))

## [v2.0.1](https://github.com/voxpupuli/onceover/tree/v2.0.1) (2015-11-16)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/2.0.0...v2.0.1)

## [2.0.0](https://github.com/voxpupuli/onceover/tree/2.0.0) (2015-11-11)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v2.0.0...2.0.0)

## [v2.0.0](https://github.com/voxpupuli/onceover/tree/v2.0.0) (2015-11-11)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/1.1.1...v2.0.0)

## [1.1.1](https://github.com/voxpupuli/onceover/tree/1.1.1) (2015-11-10)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/v1.1.0...1.1.1)

## [v1.1.0](https://github.com/voxpupuli/onceover/tree/v1.1.0) (2015-11-06)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/1.1.0...v1.1.0)

## [1.1.0](https://github.com/voxpupuli/onceover/tree/1.1.0) (2015-10-28)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/1.0.0...1.1.0)

## [1.0.0](https://github.com/voxpupuli/onceover/tree/1.0.0) (2015-10-19)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/0.2.0...1.0.0)

## [0.2.0](https://github.com/voxpupuli/onceover/tree/0.2.0) (2015-09-29)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/0.1.1...0.2.0)

## [0.1.1](https://github.com/voxpupuli/onceover/tree/0.1.1) (2015-09-28)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/0.0.1...0.1.1)

## [0.0.1](https://github.com/voxpupuli/onceover/tree/0.0.1) (2015-09-24)

[Full Changelog](https://github.com/voxpupuli/onceover/compare/192099961f3ffe616b5811815a9df013f1284e54...0.0.1)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
