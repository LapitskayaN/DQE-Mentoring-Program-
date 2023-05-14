pipeline {
    agent any
    environment {
        PYTHONPATH = '4_Test_Automation/homework_pytest/src'
    }
    stages {
        stage('test') {
            steps {
                echo 'Hello World ...'
            }
	}      
        stage('Run test') {
            steps {
                sh 'pytest 4_Test_Automation/homework_pytest'
            }
        }
    }
}
