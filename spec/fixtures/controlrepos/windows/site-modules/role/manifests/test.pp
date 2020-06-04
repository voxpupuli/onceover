class role::test {
  # ACL often causes failures such as this:
  # https://github.com/rodjek/rspec-puppet/issues/665
  #
  # Onceover should handle this out of the box
  acl { 'L:\\SQLBackup':
    inherit_parent_permissions => false,
    permissions                => [
      { 'identity' => 'foo', 'rights' => ['read'] }
    ],
  }
}
