.PHONY: up

up:
	docker-compose -f docker-compose.yml up -d

.PHONY: down

down:
	docker-compose down
	rm -rf ./oracle-volume/XE

.PHONY: logs

logs:
	docker-compose logs -f

.PHONY: rst

rst: down up logs