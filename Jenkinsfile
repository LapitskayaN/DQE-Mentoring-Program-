pipeline {
    agent any
    environment {
        PYTHONPATH = 'Module_4_TASK2_PYTEST'
    }
    stages {
        stage('test') {
            steps {
                echo 'Hello World ...'
            }
        }
        stage('version') {
            steps {
                sh 'python --version'
            }
        }
    }
}