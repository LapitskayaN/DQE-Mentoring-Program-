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
        stage('Run test') {
            steps {
                sh 'pytest Module_4_TASK2_PYTEST'
            }
        }
    }
}