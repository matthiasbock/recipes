
container:
	@if [ "$CONFIG" == "" ]; then echo "Error: CONFIG is not defined."; exit 1; fi
	@echo "Building container..."
	./containers/build.sh $CONFIG
	@echo "Finished building container."

container_image: container
	@if [ "$CONFIG" == "" ]; then echo "Error: CONFIG is not defined."; exit 1; fi
	@echo "Creating image from container..."
	./containers/commit.sh $CONFIG
	@echo "Finished creating container image."

push_image: container_image
	@if [ "$CONFIG" == "" ]; then echo "Error: CONFIG is not defined."; exit 1; fi
	@echo "Publishing container image to registry..."
	./containers/push.sh $CONFIG
	@echo "Finished publishing container image to registry."

delete_container:
	@if [ "$CONFIG" == "" ]; then echo "Error: CONFIG is not defined."; exit 1; fi
	@echo "Removing container..."
	./containers/delete.sh $CONFIG
	@echo "Finished container removal."
