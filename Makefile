LIQUIBASE_IMAGE := liquibase/liquibase
LIQUIBASE_TAG   := 4.31.1
DB_URL          := jdbc:oracle:thin:@//host.docker.internal:1521/XEPDB1

.PHONY: migrate dry-run

## dry-run: prints the SQL Liquibase would execute without applying it (updateSQL)
dry-run:
	docker run --rm \
	  --volumes-from jenkins \
	  --workdir $(WORKSPACE) \
	  $(LIQUIBASE_IMAGE):$(LIQUIBASE_TAG) \
	  --defaultsFile=$(WORKSPACE)/liquibase.properties \
	  --url="$(DB_URL)" \
	  --username="$$DB_USERNAME" \
	  --password="$$DB_PASSWORD" \
	  updateSQL

## migrate: applies pending changesets to the database (update)
migrate:
	docker run --rm \
	  --volumes-from jenkins \
	  --workdir $(WORKSPACE) \
	  $(LIQUIBASE_IMAGE):$(LIQUIBASE_TAG) \
	  --defaultsFile=$(WORKSPACE)/liquibase.properties \
	  --url="$(DB_URL)" \
	  --username="$$DB_USERNAME" \
	  --password="$$DB_PASSWORD" \
	  update
