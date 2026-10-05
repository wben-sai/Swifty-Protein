.PHONY: install postgres prisma migrate-dev run setup

install:
	npm install

postgres:
	./scripts/setup-postgres.sh

prisma:
	npx prisma generate
	npx prisma migrate deploy

run:
	npm run start:dev

setup: postgres install prisma
