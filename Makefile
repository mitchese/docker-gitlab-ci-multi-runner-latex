all: build

build:
	@docker build --tag=mitchese/docker-gitlab-ci-multi-runner-latex .

release: build
	@docker build --tag=mitchese/docker-gitlab-ci-multi-runner-latex:$(shell cat VERSION) .
