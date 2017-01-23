VERSION ?= 5.10.8
REGISTRY ?= docker.seibert-media.net

all: build upload clean
clean:
	docker rmi $(REGISTRY)/seibertmedia/atlassian-confluence:$(VERSION)
build:
	docker build --no-cache --rm=true --build-arg VERSION=$(VERSION) -t $(REGISTRY)/seibertmedia/atlassian-confluence:$(VERSION) .
upload:
	docker push $(REGISTRY)/seibertmedia/atlassian-confluence:$(VERSION)
