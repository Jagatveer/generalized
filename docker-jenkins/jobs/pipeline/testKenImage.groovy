node('jnlp-slave'){
    commitSHA = "";

  stage('Checkout') {
    git  credentialsId: 'bitbucket-ssh',branch:'master' , url:'git@bitbucket.org:nclouds/ecs-refarch-cloudformation.git'
    sh 'mkdir -p ./services/ken/src'
    dir ('services/ken/src') {
        commitSHA = sh(returnStdout: true, script: 'git rev-parse HEAD').take(6)
        commitSHA = "${commitSHA}${BUILD_NUMBER}"
        git credentialsId: 'bitbucket-ssh',branch:BRANCH_NAME , url:'git@bitbucket.org:nclouds/ken.git'
    }
  }
  stage('Docker Registry Login') {
    sh '$(aws ecr get-login --region=us-west-2)'
  }
  stage(' building ken') {
    sh "docker-compose -p ${commitSHA} -f docker-compose-test.yml build "
  }
  stage(' launching ken') {
    sh "docker-compose -p ${commitSHA} -f docker-compose-test.yml up -d ken "
    sleep (time:15,unit:"SECONDS")
  }
   stage('Running the test') {
    try{
      writeFile file: "test.sh", text: "#!/bin/bash \n " +
                                       "ls \n" +
                                       "source ../virtualenv/bin/activate \n" +
                                       "./manage.py test -- --ignore=site-packages"
      sh "docker cp test.sh  ${commitSHA}_ken_1:/var/www/html/test.sh"
      sh "docker exec -i ${commitSHA}_ken_1 /bin/bash test.sh"
    }
    catch(Exception ex){
      slackSend (color: "danger", message: "FAILED: Job '${env.JOB_NAME} -- build [${env.BUILD_NUMBER}]' on branch " + BRANCH_NAME + " ${env.BUILD_URL}console")
      throw ex
    }
    finally{
        sh "docker-compose -p ${commitSHA} -f docker-compose-test.yml down"
    }
   }

   stage('SonarQube analysis') {
     def scannerHome = tool 'sonarRunner';
     def workspace = pwd()
     withSonarQubeEnv('sonarqube') {
       sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectBaseDir=${workspace}/services/ken/src -Dsonar.branch="+BRANCH_NAME
     }
   }

  stage ('Complete') {
      slackSend (color: "good", message: "SUCCESFULL:  Job '${env.JOB_NAME} -- build [${env.BUILD_NUMBER}]' on branch " + BRANCH_NAME + " ${env.BUILD_URL}console")
  }

}
