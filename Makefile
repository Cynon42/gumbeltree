PROJECT_USER=cynon42
PROJECT_NAME=gumbeltree
PROJECT_LABEL=latest

IMAGE_TAG=${PROJECT_USER}/${PROJECT_NAME}:${PROJECT_LABEL}

DOCKER_USER=rstudio
DOCKER_UID=$(shell id -u)
DOCKER_GID=$(shell id -g)


RSTUDIO_PORT=8788

CONTAINER_NAME=gumbeltree-docker-container

### Set GITHUB_USER with 'gh config set gh_user <<user>>'
GITHUB_USER=$(shell gh config get gh_user)
GITHUB_PROJECT="gumbeltree"
GITHUB_LABEL=modelling
GITHUB_MILESTONE="Initial Models"


### Project build targets
.SUFFIXES: .Rmd .html .dot .png

RMD_FILES  := $(wildcard *.Rmd)
HTML_FILES := $(patsubst %.Rmd,%.html,$(RMD_FILES))


all-html: $(HTML_FILES)


.Rmd.html:
	Rscript -e 'rmarkdown::render("$<")'

.dot.png: 
	dot -Tpng -o$*.png $<

full_deps.dot:
	makefile2graph all-html > full_deps.dot

depgraph: full_deps.dot full_deps.png



gh-create-issue:
	gh issue create \
	  --assignee ${GITHUB_USER} \
	  --project ${GITHUB_PROJECT} \
	  --label ${GITHUB_LABEL} \
	  --milestone ${GITHUB_MILESTONE}



echo-reponame:
	echo "${REPO_NAME}"

clean-html:
	rm -rfv *.html

clean-cache:
	rm -rfv *_cache
	rm -rfv *_files

mrproper:
	rm -rfv *.html
	rm -rfv *.dot
	rm -rfv *.png
	rm -rfv *_cache
	rm -rfv *_files
	rm -rfv data/*.rds
	rm -rfv geospatial_data/*.zip
	rm -rfv geospatial_data/FRA_adm*




docker-build-image: Dockerfile
	docker build -t ${IMAGE_TAG} -f Dockerfile .

docker-run:
	docker run --rm -d \
	  -p ${RSTUDIO_PORT}:8787 \
	  -v "${PWD}":"/home/${DOCKER_USER}/${PROJECT_NAME}":rw \
	  -e USER=${DOCKER_USER} \
	  -e PASSWORD=quickpass \
	  -e USERID=${DOCKER_UID} \
	  -e GROUPID=${DOCKER_GID} \
	  --name ${CONTAINER_NAME} \
	  ${IMAGE_TAG}

docker-bash:
	docker exec -it -u ${DOCKER_USER} ${CONTAINER_NAME} bash



docker-stop:
	docker stop ${CONTAINER_NAME}

docker-clean:
	docker rm $(shell docker ps -q -a)

docker-login:
	cat $(HOME)/.dockerpass | docker login -u kaybenleroll --password-stdin

docker-pull:
	docker pull ${IMAGE_TAG}

docker-push:
	docker push ${IMAGE_TAG}
