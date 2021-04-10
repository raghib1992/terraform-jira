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
                

                sh '''
                    echo "****************************************"
                    echo "****CLONED MSTER BRANCH SUCCESSFULLY****"
                    echo "****************************************"
                '''
                
            }
        }
        stage('PREPARING GIT FOR NEW CUSTOMER') {
            steps {
              sh 'chmod +x prepare.sh'
                  
            }
            
        }
    }
}