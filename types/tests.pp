type Onceover::Tests = Array[Struct[{
  'node' => Struct[{
    'name'               => String,
    'factset'            => Optional[Hash],
    'platform'           => String,
    'provisioner'        => String,
    'post-build-tasks'   => Optional[Array[Onceover::Task]],
    'post-install-tasks' => Optional[Array[Onceover::Task]],
  }],
  'class' => String,
}]]
