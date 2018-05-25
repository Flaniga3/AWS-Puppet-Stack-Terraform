pipeline {
  agent any

  stages {
    stage ("Get and Store AMI ID") {
      steps {
        script {
          sh 'sudo /bin/bash -c \'aws ec2 describe-images --region us-east-1 --owners 185973821619 --filters "Name=name,Values=ubuntu-docker-swarm-*" --query "Images[*].{Id:ImageId,Created:CreationDate} | sort_by(@, &Created)[-1:] | @[0].Id" > ami_id.prop\''
        }
      }
    }

    stage ("Create Login Key") {
      steps {
        script {
          KEY_NAME = "jenkins_ssh_key_${(new Date()).getTime()}"
        }
        sh "/usr/bin/ssh-keygen -t rsa -b 4096 -f /tmp/${KEY_NAME} -N '' -C 'Jenkins SSH Login'"
      }
    }

    stage ("Initialize Terraform") {
      steps {
        sh "sudo /usr/bin/terraform init"
      }
    }

    stage ("Deploy Ubuntu Docker Machine") {
      environment {
        DEFAULT_AMI_ID = readFile("./ami_id.prop").trim().replaceAll("\"", "")
      }

      steps {  
        script {
          AMI_ID_REAL = input(
            message: 'Enter your desired AMI ID (Default is latest):', 
            parameters: [
              string(name: 'AMI_ID', 
              description: 'AMI ID', 
              defaultValue: "${env.DEFAULT_AMI_ID}")
            ]
          )
        }

        sh "sudo /usr/bin/terraform apply -var 'jenkins_ami=${AMI_ID_REAL}' -var 'key_name=${KEY_NAME}' --auto-approve"
      }
    }

    stage ("Clean-Up") {
      steps {
        sh "sudo /usr/bin/rm -f /tmp/login_key /tmp/login_key.pub"
      }
    }
  }
}
