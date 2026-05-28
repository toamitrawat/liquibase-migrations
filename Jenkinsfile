pipeline {
    agent any

    parameters {
        booleanParam(
            name: 'DRY_RUN',
            defaultValue: true,
            description: 'true = print SQL only (updateSQL); false = apply changes to DB (update)'
        )
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 10, unit: 'MINUTES')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Registry Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'local-registry-creds',
                    usernameVariable: 'REG_USER',
                    passwordVariable: 'REG_PASS'
                )]) {
                    sh 'make login'
                }
            }
        }

        stage('Run Migrations') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'local-oracle-db-creds',
                    usernameVariable: 'DB_USERNAME',
                    passwordVariable: 'DB_PASSWORD'
                )]) {
                    script {
                        def target = params.DRY_RUN ? 'dry-run' : 'migrate'
                        sh "make ${target}"
                    }
                }
            }
        }
    }

    post {
        always {
            sh 'make logout || true'
            cleanWs()
        }
    }
}
