pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['dry-run', 'migrate', 'rollback'],
            description: 'dry-run: preview SQL only | migrate: apply changes | rollback: revert to a previous tag'
        )
        string(
            name: 'ROLLBACK_TO_TAG',
            defaultValue: '',
            description: 'Required when ACTION=rollback. Enter the tag to roll back to (e.g. build-42)'
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

        stage('Dry Run') {
            when { expression { params.ACTION == 'dry-run' } }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'local-oracle-db-creds',
                    usernameVariable: 'DB_USERNAME',
                    passwordVariable: 'DB_PASSWORD'
                )]) {
                    sh 'make dry-run'
                }
            }
        }

        stage('Migrate') {
            when { expression { params.ACTION == 'migrate' } }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'local-oracle-db-creds',
                    usernameVariable: 'DB_USERNAME',
                    passwordVariable: 'DB_PASSWORD'
                )]) {
                    sh 'make migrate'
                    sh "RELEASE_TAG=build-${BUILD_NUMBER} make tag"
                }
            }
        }

        stage('Rollback Dry Run') {
            when { expression { params.ACTION == 'rollback' } }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'local-oracle-db-creds',
                    usernameVariable: 'DB_USERNAME',
                    passwordVariable: 'DB_PASSWORD'
                )]) {
                    sh "RELEASE_TAG=${params.ROLLBACK_TO_TAG} make rollback-dry-run"
                }
            }
        }

        stage('Rollback') {
            when { expression { params.ACTION == 'rollback' } }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'local-oracle-db-creds',
                    usernameVariable: 'DB_USERNAME',
                    passwordVariable: 'DB_PASSWORD'
                )]) {
                    input message: "Review the rollback SQL above. Proceed with rollback to tag '${params.ROLLBACK_TO_TAG}'?"
                    sh "RELEASE_TAG=${params.ROLLBACK_TO_TAG} make rollback"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
