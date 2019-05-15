@Library('mobile-libs') _

pipeline {
  agent any
  environment {
    PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    RUBY_VERSION = "2.5"
  }
  options {
    buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
  }
  stages {
    stage ('Bootstrap') {
      steps {
        echo "Executing on ${NODE_NAME}"
        rubyCMD "bundle install"
      }
    }

    stage ('Test') {
      options {
        timeout(time: 10, unit: "MINUTES")
      }
      steps {
        fastlane "test"
      }
    }
  }
  post {
    always {
      archiveArtifacts allowEmptyArchive: true, artifacts: 'Build/**/*'
      archiveArtifacts allowEmptyArchive: true, artifacts: 'fastlane/test_output/report.html'
      junit allowEmptyResults: true, testResults: 'fastlane/test_output/report.junit'

      publishHTML (target: [
        allowMissing: true,
        alwaysLinkToLastBuild: false,
        keepAll: true,
        reportDir: 'fastlane/test_output/xcov',
        reportFiles: 'index.html',
        reportName: "XCov Report"
      ])

      publishHTML (target: [
        allowMissing: true,
        alwaysLinkToLastBuild: false,
        keepAll: true,
        reportDir: 'fastlane/test_output',
        reportFiles: 'report.html',
        reportName: "Test Report"
      ])
    }
  }
}
