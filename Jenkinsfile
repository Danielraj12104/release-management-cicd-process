pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Salesforce CLI') {
            steps {
                bat 'sf --version'
            }
        }
    }
}