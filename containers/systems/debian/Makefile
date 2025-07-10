

PROJECT_ROOT=$(abspath ../../..)


.PHONY: bookworm-amd64
bookworm-amd64:
	cd "$(PROJECT_ROOT)" && \
	docker build -f containers/systems/debian/Dockerfile.bookworm-amd64 -t debian:bookworm-amd64 .


.PHONY: push
push:
	docker tag debian:bookworm-amd64 git-registry.charite.de:443/predicardio/studies/cryo/debian:bookworm-amd64
	docker push git-registry.charite.de:443/predicardio/studies/cryo/debian:bookworm-amd64


.PHONY: clean
clean:

