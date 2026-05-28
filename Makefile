LIQUIBASE_IMAGE := liquibase/liquibase
LIQUIBASE_TAG   := 4.31.1
DB_URL          := jdbc:oracle:thin:@//host.docker.internal:1521/XEPDB1

# CI_CONTAINER: name of the CI agent container whose volumes Liquibase inherits.
# Override per CI tool — e.g.  CI_CONTAINER=gocd-agent make migrate
CI_CONTAINER ?= jenkins

# WORKSPACE: absolute path to the pipeline working directory on the agent.
# Jenkins sets this automatically. For GoCD (or local runs) we fall back to pwd.
WORKSPACE ?= $(shell pwd)

LIQUIBASE_RUN = docker run --rm \
	  --volumes-from $(CI_CONTAINER) \
	  --workdir $(WORKSPACE) \
	  $(LIQUIBASE_IMAGE):$(LIQUIBASE_TAG) \
	  --defaultsFile=$(WORKSPACE)/liquibase.properties \
	  --url="$(DB_URL)" \
	  --username="$$DB_USERNAME" \
	  --password="$$DB_PASSWORD"

.PHONY: validate status dry-run migrate tag rollback rollback-dry-run

## validate: checks the changelog for errors without touching the DB
validate:
	$(LIQUIBASE_RUN) validate

## status: lists changesets not yet applied to the DB
status:
	$(LIQUIBASE_RUN) status --verbose

## dry-run: prints the SQL Liquibase would execute and saves it to liquibase-dry-run.sql
dry-run:
	$(LIQUIBASE_RUN) updateSQL > $(WORKSPACE)/liquibase-dry-run.sql 2>&1 || \
	  (cat $(WORKSPACE)/liquibase-dry-run.sql; exit 1)

## migrate: applies pending changesets to the database
migrate:
	$(LIQUIBASE_RUN) update

## tag: stamps current DB state with the given RELEASE_TAG
tag:
	$(LIQUIBASE_RUN) tag "$$RELEASE_TAG"

## rollback-dry-run: shows SQL that rollback would execute without touching the DB
rollback-dry-run:
	$(LIQUIBASE_RUN) rollbackSQL "$$RELEASE_TAG"

## rollback: rolls back all changesets applied after the given RELEASE_TAG
rollback:
	$(LIQUIBASE_RUN) rollback "$$RELEASE_TAG"
