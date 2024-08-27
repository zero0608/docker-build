


# Commands

build:

    docker build -t alpine-rbenv --rm=true .


debug:

    docker run -i -t --entrypoint=sh alpine-rbenv


run:

    docker run -p 9000:9000 -e UID=`id -u $USER` -e GID=`id -g $USER` --name alpine-rbenv -v ~/git:/home/dev/git -i -P alpine-rbenv


login:

    docker exec -i -t -u dev alpine-rbenv bash


logout:

    exit

docker push:
    DOCKER_BUILDKIT=1 docker build -t ruby-on-rails .
    docker tag ruby-on-rails zero4636/ruby-on-rails:3.3.4
    docker push zero4636/ruby-on-rails:3.3.4