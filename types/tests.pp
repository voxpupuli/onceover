type Onceover::Tests = Array[Struct[{
  'node' => Struct[{
    'name'               => String,
    'factset'            => Optional[Hash],
    'platform'           => String,
    'provisioner'        => String,
    'post-build-tasks'   => Optional[Onceover::Task],
    'post-install-tasks' => Optional[Onceover::Task],
  }],
  'class' => String,
}]]
