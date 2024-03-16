class profile::rvm {
  include ::rvm

  rvm_system_ruby { 'ruby-2.3.3':
    ensure      => 'present',
    default_use => true,
  }

  rvm_gem { 'ruby-2.3.3/bundler':
      ensure  => latest,
      require => Rvm_system_ruby['ruby-2.3.3'],
  }
}
