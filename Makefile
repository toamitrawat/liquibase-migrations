LIQUIBASE_IMAGE := liquibase/liquibase
LIQUIBASE_TAG   := 4.31.1
DB_URL          := jdbc:oracle:thin:@//host.docker.internal:1521/XEPDB1

LIQUIBASE_RUN = docker run --rm \
	  --volumes-from jenkins \
	  --workdir $(WORKSPACE) \
	  $(LIQUIBASE_IMAGE):$(LIQUIBASE_TAG) \
	  --defaultsFile=$(WORKSPACE)/liquibase.properties \
	  --url="$(DB_URL)" \
	  --username="$$DB_USERNAME" \
	  --password="$$DB_PASSWORD"

.PHONY: dry-run migrate tag rollback rollback-dry-run

## dry-run: prints the SQL Liquibase would execute without applying it (updateSQL)
dry-run:
	$(LIQUIBASE_RUN) updateSQL

## migrate: applies pending changesets then tags the state with BUILD_NUMBER
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
