docker-local:
	docker buildx build --platform linux/arm64 -t tenox7/vncbrave:latest --load .

docker-push:
	docker buildx build --platform linux/amd64,linux/arm64 -t tenox7/vncbrave:latest --push .

clean:
	docker rmi -f tenox7/vncbrave:latest
