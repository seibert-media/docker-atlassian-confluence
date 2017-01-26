ATLASSIAN_VERSION ?= $(VERSION)
REGISTRY ?= docker.seibert-media.net

default: build

all: checkvars build upload clean

build: checkvars
	docker build --no-cache --rm=true --build-arg VERSION=$(ATLASSIAN_VERSION) -t $(REGISTRY)/seibertmedia/atlassian-confluence:$(VERSION) .

clean: checkvars
	docker rmi $(REGISTRY)/seibertmedia/atlassian-confluence:$(VERSION)

upload: checkvars
	docker push $(REGISTRY)/seibertmedia/atlassian-confluence:$(VERSION)

checkvars:
ifndef VERSION
	$(error env variable VERSION has to be set)
endif
