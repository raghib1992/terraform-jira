pipeline {
    agent any
    
    environment {
        SECRET_TEXT=credentials("AWS_SECRET_KEY_FOLIUM")
        NEW_CUSTOMER="$JENKINS_INPUT_NEW_CUSTOMER"
    }
    stages {
        stage('PREPARING GIT FOR NEW CUSTOMER') {
            steps {
                sh '''
                    cd /var/jenkins_home/workspace/terraform-pipeline/ec2/ && \
                    ls -l && \
                    pwd && \
                    chmod +x /prepare.sh' && \
                    ./prepare.sh $NEW_CUSTOMER
                    '''             
            }
            
        }
        stage('deploying new infra for new customer') {
            steps {
                sh 'chmod +x ec2/infra.sh'
                sh './ec2/infra.sh $SECRET_TEXT'                    
            }            
        }
    }
    
}