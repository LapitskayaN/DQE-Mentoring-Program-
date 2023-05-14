pipeline {
    agent any
    stages {
        stage('test') {
            steps {
                echo 'Hello World ...'
            }
	} 
        stage('install requirements') {
            steps {
                sh 'pip install -r Module_4_TASK2_PYTEST/requirements.txt'
            }
        }       
        stage('Run test') {
            steps {
                sh 'pytest Module_4_TASK2_PYTEST/test_cases.py'
            }
        }
    }
}