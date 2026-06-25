# Docker Registry

## Setup

- Create directories
  ```
  mkdir -p registry-data auth
  ```
- Create the htpasswd file 
  ```
  docker run --rm \
      --entrypoint htpasswd \
      httpd:2 \
      -Bbn myuser mypassword > auth/htpasswd
  ```

- Check authentication
  ```
  curl -i http://localhost:5000/v2/
  ```

- Login
  ```
  docker login localhost:5000
  ```

- Push image
  ```
  docker pull biremeapp
  docker tag biremeapp localhost:5000/biremeapp:latest
  docker push localhost:5000/biremeapp:latest
  ```

- Pull image
  ```
  docker pull localhost:5000/biremeapp:latest
  ```
