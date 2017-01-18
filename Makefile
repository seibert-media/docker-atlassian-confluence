VERSION ?= 5.10.8
MYSQL_JDBC_VERSION ?= 5.1.40
REGISTRY ?= docker.seibert-media.net

all: build upload clean
clean:
	docker rmi $(REGISTRY)/seibertmedia/atlassian-confluence:$(VERSION)
build:
	docker build --no-cache --rm=true --build-arg VERSION=$(VERSION) --build-arg MYSQL_JDBC_VERSION=$(MYSQL_JDBC_VERSION) -t $(REGISTRY)/seibertmedia/atlassian-confluence:$(VERSION) .
upload:
	docker push $(REGISTRY)/seibertmedia/atlassian-confluence:$(VERSION)
