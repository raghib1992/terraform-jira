pipeline {
    agent any
    
    environment {
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
        stage('deploying new infra for new customer') {
            steps {
                sh '''
                    cd ec2/
                    sed -i "s|aws-password|$AWS_SECRET|g" terraform.tfvars
                    ssh-keygen -f test-key
            }
            
        }
    }
}