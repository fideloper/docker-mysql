# Docker MySQL Server

To use, edit the included `build/setup.sh` so it creates a database, user and password to your needs. A future update will let you define which host/ip to use when creating the user permissions.

Then, build the Docker container:

```bash
# cd into the git repository
cd /path/to/repo/docker-mysql
docker build -t mysql .    # Build a Docker image named "mysql" from this location "."
# wait for it to build...

# Run the docker container
docker run -p 3306:3306 -name mysql -d mysql /sbin/my_init --enable-insecure-key # Give container a name in case it's linked to another app container
```

* `docker run` - starts a new docker container
* * `-p 3306:3306` - Binds the local port 3306 to the container's port 3306, so a local.
* * `-d mysql` - Use the image tagged "mysql"
* * `/sbin/my_init` - Run the init scripts used to kick off long-running processes and other bootstrapping, as per [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker)
* * `--enable-insecure-key` - Enable a generated SSL key so you can SSH into the container, again as per [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker). Generate your own SSH key for production use.
* * If you use this with [fideloper/docker-nginx-php](https://github.com/fideloper/docker-nginx-php), then naming this container via `-name mysql` will allow you to [link it](http://docs.docker.io/en/latest/use/working_with_links_names/) with the web-app.
