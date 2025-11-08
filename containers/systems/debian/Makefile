
PROJECT_ROOT=$(abspath ../../..)

RELEASE=bookworm
ARCH=amd64

TEMPLATE=$(abspath Dockerfile.j2)
DOCKERFILE=$(TEMPLATE:.j2=.$(RELEASE)-$(ARCH))

REGISTRY=git-registry.charite.de:443
REPO=predicardio/studies/cryo
IMAGE=debian:$(RELEASE)-$(ARCH)
TAG=$(REGISTRY)/$(REPO)/$(IMAGE)


.PHONY: all
all: $(RELEASE)-$(ARCH)


.PHONY: nvidia-list-installed
nvidia-list-installed:
	apt list --installed 2>/dev/null | fgrep -i nvidia | cut -d/ -f1


.SECONDARY: $(DOCKERFILE)
.PHONY: $(RELEASE)-$(ARCH)
$(RELEASE)-$(ARCH): $(DOCKERFILE)
$(DOCKERFILE): $(TEMPLATE)
	jinja2 $(TEMPLATE) > $(DOCKERFILE)


.PHONY: build
build: $(DOCKERFILE)
	cd "$(PROJECT_ROOT)" && \
	docker build -f $(DOCKERFILE) -t $(TAG) .


.PHONY: push
push:
	docker login
	docker push $(TAG)


.PHONY: clean
clean:
	rm -f $(DOCKERFILE)

