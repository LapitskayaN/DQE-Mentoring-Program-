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
                sh 'pytest test.py'
            }
        }
    }
}