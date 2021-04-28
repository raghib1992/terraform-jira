pipeline {
    agent any
    
    environment {
       SECRET_TEXT=credentials("AWS_SECRET_KEY_FOLIUM")
       // NEW_CUSTOMER="$JENKINS_INPUT_NEW_CUSTOMER"
    }
    stages {
        stage('PREPARING GIT FOR NEW CUSTOMER') {
            steps {
                sh '''
                    cd /var/lib/jenkins/workspace/aws-saas-terraform/ec2/
                    ls -l
                    pwd
                    chmod +x prepare.sh
                    ./prepare.sh foliumcloud
                  '''             
            }
            
        }
        stage('Creating new branch for new customer') {
            steps {
                sh '''
                    cd /var/lib/jenkins/workspace/aws-saas-terraform/ec2/
                    chmod +x infra.sh
                    ./infra.sh $SECRET_TEXT
                  '''
            }            
        }
        stage('deploying new infra for new customer') {
            steps {
                sh '''
                    cd /var/lib/jenkins/workspace/aws-saas-terraform/ec2/
                    terraform init
                    terraform plan
                    terraform apply -auto-approve                   
                  '''
            }            
        }
    }
    
}
