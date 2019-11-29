
help:
	@echo "run_base_image    - Run base Docker image, useful for extracting base files that we want to modify"
	@echo "stop_base_image   - Delete base Docker container when we are done extracting what we want"
	@echo "build_test_image  - Build our test image"
	@echo "run_test_image    - Run our test image"
	@echo "delete_test_image - Delete our test image"

run_base_image:
	sudo docker run --rm --name tmp-nginx-container -d nginx:stable-alpine

stop_base_image:
	sudo docker stop tmp-nginx-container

build_test_image:
	sudo docker build -t nishedcob/demo-static-app:test .

run_test_image:
	sudo docker run --name test-demo-static-app --rm -p 80:80 nishedcob/demo-static-app:test

delete_test_image:
	sudo docker rmi nishedcob/demo-static-app:test
