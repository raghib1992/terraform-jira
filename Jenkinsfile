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
                    cd /var/jenkins_home/workspace/terraform-pipeline/ec2/
                    ls -l
                    pwd
                    chmod +x prepare.sh
                    ./prepare.sh $NEW_CUSTOMER
                  '''             
            }
            
        }
        stage('Creating new branch for new customer') {
            steps {
                sh '''
                    cd /var/jenkins_home/workspace/terraform-pipeline/ec2/
                    chmod +x infra.sh
                    ./infra.sh $SECRET_TEXT
                  '''
            }            
        }
        stage('deploying new infra for new customer') {
            steps {
                sh '''
                    cd /var/jenkins_home/workspace/terraform-pipeline/ec2/
                    terraform init
                    terraform plan
                    terraform apply -auto-approve                   
                  '''
            }            
        }
    }
    
}