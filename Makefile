
SUDO=
#SUDO=sudo
DOCKER=$(SUDO) docker
PIP_NINJA_GIT_PATCH=s_ninja2==0\.2_-e git+https://github.com/sspreitzer/ninja2@0.2\#egg=ninja2_
PIP_GIT_PATCHES=sed '$(PIP_NINJA_GIT_PATCH)'

help:
	@echo "run_base_image    - Run base Docker image, useful for extracting base files that we want to modify"
	@echo "stop_base_image   - Delete base Docker container when we are done extracting what we want"
	@echo "build_test_image  - Build our test image"
	@echo "run_test_image    - Run our test image"
	@echo "delete_test_image - Delete our test image"

run_base_image:
	$(DOCKER) run --rm --name tmp-nginx-container -d nginx:stable-alpine

stop_base_image:
	$(DOCKER) stop tmp-nginx-container

env: requirements.txt
	virtualenv --python python3 env
	env/bin/pip install -r requirements.txt

config.json: config.yaml env
	env/bin/yq '.' $< > $@

index.html: index.html.j2 config.json env
	env/bin/ninja2 -j $< < config.json > $@
	rm -rdvf env
	rm -v config.json

build_test_image: index.html
	$(DOCKER) build -t nishedcob/demo-static-app:test .
	rm -v $<

run_test_image:
	$(DOCKER) run --name test-demo-static-app --rm -p 80:80 nishedcob/demo-static-app:test

delete_test_image:
	$(DOCKER) rmi nishedcob/demo-static-app:test

pipenv_freeze:
	pipenv run pip freeze | $(PIP_GIT_PATCHES) > requirements.txt
	pipenv install -r requirements.txt
