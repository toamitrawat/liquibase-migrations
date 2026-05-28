REGISTRY        := host.docker.internal:5001
LIQUIBASE_IMAGE := liquibase-oracle
LIQUIBASE_TAG   := 4.31.1
DB_URL          := jdbc:oracle:thin:@//host.docker.internal:1521/XEPDB1

.PHONY: login logout migrate dry-run

login:
	echo "$$REG_PASS" | docker login $(REGISTRY) -u "$$REG_USER" --password-stdin

## dry-run: prints the SQL Liquibase would execute without applying it (updateSQL)
dry-run:
	docker run --rm \
	  --volumes-from jenkins \
	  --workdir $(WORKSPACE) \
	  $(REGISTRY)/$(LIQUIBASE_IMAGE):$(LIQUIBASE_TAG) \
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
	  $(REGISTRY)/$(LIQUIBASE_IMAGE):$(LIQUIBASE_TAG) \
	  --defaultsFile=$(WORKSPACE)/liquibase.properties \
	  --url="$(DB_URL)" \
	  --username="$$DB_USERNAME" \
	  --password="$$DB_PASSWORD" \
	  update

logout:
	docker logout $(REGISTRY)
