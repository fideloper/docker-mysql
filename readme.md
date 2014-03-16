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
