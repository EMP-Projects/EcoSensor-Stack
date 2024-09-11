stack-db:
	docker compose --env-file .env.stack -f docker-compose.yml -p ecosensor --profile db down
	docker compose --env-file .env.stack -f docker-compose.yml -p ecosensor --profile db up -d

stack:
	docker compose --env-file .env.stack -f docker-compose.yml -p ecosensor --profile all down
	docker compose --env-file .env.stack -f docker-compose.yml -p ecosensor --profile all up -d