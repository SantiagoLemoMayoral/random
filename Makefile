setup:
	python -m pip install -r backend/requirements.txt

test:
	python -m pytest

lint:
	ruff check .

docker-build:
	docker build -t random:local .

helm-template:
	helm template random helm/random

tf-fmt:
	terraform -chdir=infra/terraform/modules fmt -check

tf-validate:
	terraform -chdir=infra/terraform/modules validate

check: lint test helm-template tf-fmt tf-validate