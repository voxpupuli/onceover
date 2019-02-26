# Class: role::groups
#
#
class role::groups {
  group {'Administrators':
    members => ['foo'],
  }
}
