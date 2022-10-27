.PHONY: up

up:
	docker-compose build
	docker-compose -f docker-compose.yml up -d

.PHONY: down

down:
	docker-compose down

.PHONY: logs

logs:
	docker-compose logs -f

.PHONY: rst

rst: down up logs