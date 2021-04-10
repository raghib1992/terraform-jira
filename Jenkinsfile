pipeline {
    agent any
    
    environment {
        AWS_ACCESS="AKIARFH3I6UWWE67AKRF"
        AWS_SECRET=credentials("AWS_SECRET_KEY_FOLIUM")
        NEW_CUSTOMER="$JENKINS_INPUT_NEW_CUSTOMER"

    }
    stages {
        stage('CLONING FROM MASTER BRANCH') {
            steps {
                sh '''
                    echo "***************************************"
                    echo "*******clone from master branch********"
                    echo "***************************************"
                '''
                # git branch: 'master', changelog: false, poll: false, url: 'https://github.com/raghib1992/terraform-jira.git'

                sh '''
                    echo "****************************************"
                    echo "****CLONED MSTER BRANCH SUCCESSFULLY****"
                    echo "****************************************"
                '''
                
            }
        }
        stage('PREPARING GIT FOR NEW CUSTOMER') {
            steps {
              sh 'echo "success"'
                  
            }
            
        }
    }
}