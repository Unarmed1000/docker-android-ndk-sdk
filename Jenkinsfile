#!/usr/bin/env groovy
node('ubuntu')
{
    properties([[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '5']]]);

    // some basic config
    def DOCKERHUB_USERNAME = 'NotDefined'

    def IMAGE_TAG         = (env.BRANCH_NAME == 'r20b'  ? 'r20b' : 'r20b-dev')

    def DOCKERAPITESTUBUNTU_PATH_READONLY_CACHE = env.DOCKERAPITESTUBUNTU_PATH_READONLY_CACHE    

    def IMAGE_ARGS        = '--pull --no-cache .'
    
    // Workaround a current issue with docker.withRegistry
    // https://issues.jenkins-ci.org/browse/JENKINS-38018 
    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'docker-hub-cred-s',
                    usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) 
    {
      sh 'docker login -u "$USERNAME" -p "$PASSWORD"'
      DOCKERHUB_USERNAME = USERNAME
    }      

    def IMAGE_NAME        = "$DOCKERHUB_USERNAME/android-ndk-sdk"

    def app
    
    stage('Checkout SCM') 
    {
        // Let's make sure we have the repository cloned to our workspace
        checkout scm
    }

    stage('Build image') 
    {
        // This builds the actual image; synonymous to docker build on the command line
        app = docker.build("${IMAGE_NAME}:${IMAGE_TAG}", "${IMAGE_ARGS}")
    }

    stage('Push image') 
    {
        app.push("${IMAGE_TAG}")
    }
}
