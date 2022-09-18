pipeline{
    agent any
    stages{
        stage('Clone Git'){
            steps{
                sh 'ls -al'
                sh 'pwd'
            }
        }
        stage('Terraform Init & Plan'){
            when{
                expression{
                    params.TERRAFORM_ACTION == 'DEPLOY'
                }
            }
            steps{
                sh 'terraform init'
                sh 'terraform validate'
                sh 'terraform plan'
            }
        }
        stage('Terraform Apply'){
            when{
                expression{
                    params.TERRAFORM_ACTION == 'DEPLOY'
                }
            }
            steps{
                sh 'terraform init'
                sh 'terraform apply --auto-approve'
                sh 'terraform state list'
            }
        }
        stage('Terraform Destroy'){
            when{
                expression{
                    params.TERRAFORM_ACTION == 'DESTROY'
                }
            }
            steps{
                sh 'terraform init'
                sh 'terraform destroy --auto-approve'
            }
        }
    }
}