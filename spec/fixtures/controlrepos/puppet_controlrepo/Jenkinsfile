node {
  puppet.credentials 'PE-Deploy-Token'
  stage('Git Checkout') { // for display purposes
    // Get some code from a GitHub repository
    checkout([
      $class: 'GitSCM',
      branches: [[name: env.BRANCH_NAME]],
      doGenerateSubmoduleConfigurations: false,
      userRemoteConfigs: [[url: 'https://github.com/dylanratcliffe/puppet_controlrepo.git']]])
  }
  stage('Install Gems') {
    // Run the onceover tests
    sh '''source /usr/local/rvm/scripts/rvm && bundle install --path=.gems --binstubs'''
  }
  stage('Run Onceover Tests') {
    // Run the onceover tests
    try {
      sh '''source /usr/local/rvm/scripts/rvm && ./bin/onceover run spec'''
    } catch (error) {
      junit '.onceover/spec.xml'
      throw error
    }
  }
  stage('Deploy Code') {
    echo env.BRANCH_NAME
    puppet.codeDeploy env.BRANCH_NAME
  }
  stage('Run Puppet') {
    // Get all of the classes that have changed
    changedClasses    = sh(returnStdout: true, script: './scripts/get_changed_classes.rb').trim().split('\n')
    // Get the number of classes that have changed
    numChangedClasses = sh(returnStdout: true, script: './scripts/count_changed_classes.rb').trim().toInteger()
    // Generate a query that we will use
    nodeQuery         = ('nodes { resources { type = "Class" and title in ' + ("[\"" + changedClasses.join("\",\"") + "\"]") + ' } and catalog_environment = "' + env.BRANCH_NAME +'" }').toString()
    // If things have changed then execute the query
    if (numChangedClasses > 0) {
      echo nodeQuery
      affectedNodes  = puppet.query nodeQuery
      // If nothing has been affected by the change we don't need to try to
      // initiate the run
      if (affectedNodes.size() > 0) {
        puppet.job env.BRANCH_NAME, query: nodeQuery
      } else {
        echo "Classes: " + changedClasses.join(",") + " changed. But no nodes were affected, skipping run."
      }
    } else {
      echo "No classes changed, skipping this step."
    }
  }
}
