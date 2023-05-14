pipeline {
    agent any
    stages {
        stage('test') {
            steps {
                echo 'Hello World ...'
            }
	}      
        stage('Run test') {
            steps {
                sh 'pytest Module_4_TASK2_PYTEST/test_cases.py'
            }
        }
    }
}