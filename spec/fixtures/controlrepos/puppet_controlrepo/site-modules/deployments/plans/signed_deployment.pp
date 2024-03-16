# This deployment policy will perform a Puppet code deploy of the commit
# associated with a Pipeline run. Puppet nodes that are scheduled to run regularly will then pick up the
# change until all nodes in the target environment are running against the new
# code.
#
# @summary This deployment policy will perform a Puppet code deploy of the commit
#          associated with a Pipeline run. 
#
# @param deployment_server The fqdn of the primary Puppet server that code should be deployed to
# @param signing_secret Sensitve valie of a signining secret. This can be any string and needs to be the same as what was set on the
#   target server
plan deployments::signed_deployment (
  String            $deployment_server,
  Sensitive[String] $signing_secret = Sensitive('puppetlabs'),
) {
  # Gather all the data that we possibly can
  $deployment_info = {
    'cd4pe_pipeline_id'      => system::env('CD4PE_PIPELINE_ID'),
    'module_name'            => system::env('MODULE_NAME'),
    'control_repo_name'      => system::env('CONTROL_REPO_NAME'),
    'branch'                 => system::env('BRANCH'),
    'commit'                 => system::env('COMMIT'),
    'node_group_id'          => system::env('NODE_GROUP_ID'),
    'node_group_environment' => system::env('NODE_GROUP_ENVIRONMENT'),
    'repo_target_branch'     => system::env('REPO_TARGET_BRANCH'),
    'environment_prefix'     => system::env('ENVIRONMENT_PREFIX'),
    'repo_type'              => system::env('REPO_TYPE'),
    'deployment_domain'      => system::env('DEPLOYMENT_DOMAIN'),
    'deployment_id'          => system::env('DEPLOYMENT_ID'),
    'deployment_token'       => system::env('DEPLOYMENT_TOKEN'),
    'deployment_owner'       => system::env('DEPLOYMENT_OWNER'),
  }

  # Wait for approval if the environment is protected
  $approval_info = cd4pe_deployments::wait_for_approval($deployment_info['node_group_environment']) |String $url| { }

  $update_git_ref_result = cd4pe_deployments::update_git_branch_ref(
    $deployment_info['repo_type'],
    $deployment_info['repo_target_branch'],
    $deployment_info['commit']
  )

  $signature_data = $deployment_info + {
    'approval'       => $approval_info,
    'git_ref_update' => $update_git_ref_result,
  }

  # Create the signature
  $signature = deployments::generate(
    $signature_data,
    $signing_secret.unwrap,
  )

  # Register the signature
  run_task(
    'deployment_signature::register',
    $deployment_server,
    {
      'commit_hash'   => $deployment_info['commit'],
      'environment'   => $deployment_info['node_group_environment'],
      'data'          => $signature,
    }
  )

  # Execute all code deployment tasks in a catch block so that we can do
  # cleanup if we need to
  $outcome = catch_errors() || {
    # Deploy code
    run_task(
      'deployment_signature::r10k_deploy',
      $deployment_server,
      {
        'environment' => $deployment_info['node_group_environment'],
      }
    )

    # Write signature
    run_task(
      'deployment_signature::write',
      $deployment_server,
      {
        'environment' => $deployment_info['node_group_environment'],
      }
    )

    # Validate
    run_task(
      'deployment_signature::validate',
      $deployment_server,
      {
        'environment' => $deployment_info['node_group_environment'],
      }
    )

    # Commit
    run_task(
      'deployment_signature::file_sync_commit',
      $deployment_server,
      {
        'message'      => "Deployed with a valid signature and approval dated: ${signature_data.dig('approval', 'result', 'approvalDecisionDate')}",
        'name'         => "${signature_data.dig('approval', 'result', 'approverUsername')}",
        'email'        => 'NA',
        'submodule_id' => $deployment_info['node_group_environment'],
      }
    )
  }

  if $outcome =~ Error {
    # Clean Up
    run_task(
      'deployment_signature::cleanup',
      $deployment_server,
      {
        'environment' => $deployment_info['node_group_environment'],
        'commit_hash' => $deployment_info['commit'],
      }
    )

    fail_plan($outcome)
  } else {
    # End nicely
    return({
      'state' => 'success',
    })
  }
}
