pipeline {
  agent any

  environment {
    IMAGE_NAME = "demo-clock-app"
    IMAGE_TAG = "${env.BUILD_NUMBER}"
    CONTAINER_NAME = "clock-demo"
    APP_PORT = '3000'
  }

  options {
    skipDefaultCheckout(false)
    timestamps()
    ansiColor('xterm')
  }

  triggers {
    // Requires GitHub plugin and a webhook to http(s)://<jenkins-host>/github-webhook/
    githubPush()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Image') {
      steps {
        script {
          sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
        }
      }
    }

    stage('Stop Previous Container') {
      steps {
        script {
          sh 'docker rm -f ${CONTAINER_NAME} || true'
        }
      }
    }

    stage('Run Container') {
      steps {
        script {
          sh 'docker run -d --name ${CONTAINER_NAME} -p ${APP_PORT}:${APP_PORT} ${IMAGE_NAME}:${IMAGE_TAG}'
        }
      }
    }

    stage('Health Check') {
      steps {
        script {
          sh 'sleep 2 && curl -fsS http://localhost:${APP_PORT}/healthz | cat'
        }
      }
    }
  }

  post {
    always {
      echo "Build ${currentBuild.currentResult}: Image ${IMAGE_NAME}:${IMAGE_TAG}"
    }
  }
}


