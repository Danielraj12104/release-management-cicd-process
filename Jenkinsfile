pipeline {
    agent any

    environment {
        SF_AUTH_URL = credentials('salesforce-auth-url')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate Environment') {
            steps {
                bat 'sf --version'
            }
        }

        stage('Authenticate Salesforce') {
            steps {
                writeFile file: 'auth.txt', text: env.SF_AUTH_URL
                bat 'sf org login sfdx-url --sfdx-url-file auth.txt --alias JenkinsOrg --set-default'
            }
        }

        stage('Verify Authentication') {
            steps {
                bat 'sf org list'
            }
        }
        stage('Deploy to Salesforce') {
    steps {
        bat 'sf project deploy start --source-dir force-app --target-org JenkinsOrg --test-level NoTestRun'
    }
}
    }
}   