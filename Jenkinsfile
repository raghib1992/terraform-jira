pipeline {
    agent any
    
    environment {
        AWS_ACCESS="AKIARFH3I6UWWE67AKRF"
        AWS_SECRET=credentials("AWS_SECRET_KEY_FOLIUM")
        NEW_CUSTOMER="$JENKINS_INPUT_NEW_CUSTOMER"

    }
    stages {
        stage('PREPARING GIT FOR NEW CUSTOMER') {
            steps {
              sh 'chmod +x ec2/prepare.sh'
              sh './ec2/prepare.sh $NEW_CUSTOMER'             
            }
            
        }
    }
}