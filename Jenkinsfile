pipeline {
  agent any
  options { timestamps() }

  environment {
    AWS_REGION     = 'ap-south-1'                         // change if needed
    DOCKERHUB_REPO = 'baskarb/aws-devops-app'             // <--- your Docker Hub repo
  }

  stages {
    stage('Prepare') {
      steps {
        script {
          // Map branch -> environment/workspace name
          def b = env.BRANCH_NAME ?: 'dev'
          if (!(b in ['dev','staging','prod'])) {
            error "Unsupported branch: ${b}. Use dev, staging, or prod."
          }
          env.TARGET_ENV  = b
          env.IMAGE_TAG   = "${b}-${env.BUILD_NUMBER}"
          env.DOCKER_IMAGE = "${env.DOCKERHUB_REPO}:${env.IMAGE_TAG}"
          env.LATEST_TAG   = "latest-${b}"
        }
        sh 'echo "Deploying env=$TARGET_ENV image=$DOCKER_IMAGE latest=$LATEST_TAG"'
      }
    }

    stage('Build Docker') {
      when { anyOf { branch 'dev'; branch 'staging'; branch 'prod' } }
      steps {
        sh '''
          docker build -t "$DOCKER_IMAGE" .
          docker tag "$DOCKER_IMAGE" "$DOCKERHUB_REPO:$LATEST_TAG"
        '''
      }
    }

    stage('Push Docker') {
      when { anyOf { branch 'dev'; branch 'staging'; branch 'prod' } }
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-cred', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
          sh '''
            echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
            docker push "$DOCKER_IMAGE"
            docker push "$DOCKERHUB_REPO:$LATEST_TAG"
          '''
        }
      }
    }

    stage('Terraform Apply') {
  when { anyOf { branch 'dev'; branch 'staging'; branch 'prod' } }
  steps {
    dir('infra') {
      withCredentials([
        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
      ]) {
        script {
          sh """
            terraform init -upgrade
            terraform workspace select $TARGET_ENV || terraform workspace new $TARGET_ENV
            terraform apply -auto-approve -var-file="env/${TARGET_ENV}.tfvars"
          """
          env.PUBLIC_IP = sh(script: 'terraform output -raw public_ip', returnStdout: true).trim()
          echo "Public IP: ${env.PUBLIC_IP}"
        }
      }
    }
  }
}

    stage('Approval for PROD') {
      when { branch 'prod' }
      steps {
        input message: 'Deploy to PRODUCTION?', ok: 'Deploy'
      }
    }

    stage('Deploy over SSH') {
  when { anyOf { branch 'dev'; branch 'staging'; branch 'prod' } }
  steps {
    stage('Deploy over SSH') {
    sshagent(['ec2-user']) {
        sh '''
            ssh -o StrictHostKeyChecking=no ec2-user@${public_ip} <<EOF
            docker stop devops-app || true
            docker rm devops-app || true
            docker run -d --name devops-app -p 3000:3000 baskarb/aws-devops-app:${BUILD_TAG}
            EOF
        '''
    }
}
    }
    echo "App URL: http://$PUBLIC_IP"
  }
}
  }

  post {
    always { cleanWs() }
  }
}

