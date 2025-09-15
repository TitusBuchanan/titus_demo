# Demo Clock App

A super simple clock web app served by Node/Express, containerized with Docker, and deployable via Jenkins.

## Local development

Requirements: Node 18+ (or Docker)

### Run with Node

```bash
npm install
npm start
# open http://localhost:3000
```

### Run with Docker

```bash
docker build -t demo-clock-app:local .
docker run -d --name clock-demo -p 3000:3000 demo-clock-app:local
# open http://localhost:3000
```

### Health check

```bash
curl http://localhost:3000/healthz
```

### Container lifecycle commands

```bash
# stop the running container
docker stop clock-demo

# remove the container
docker rm -f clock-demo

# start an existing stopped container
docker start clock-demo

# View logs
docker logs -f clock-demo

# list container (any state)
docker ps -a --filter name=clock-demo
```

### Troubleshooting

- **Docker daemon not running (Mac):** Launch Docker Desktop from Applications, then wait until the whale icon shows "running".
  - Optional CLI wait loop:
    ```bash
    open -a "Docker" || open -a "Docker Desktop" || true
    until docker info >/dev/null 2>&1; do echo "waiting for docker..."; sleep 2; done
    docker version
    ```
- **Container name already in use:**
  - Error: "Conflict. The container name \"/clock-demo\" is already in use..."
  - Fix:
    ```bash
    docker rm -f clock-demo
    docker run -d --name clock-demo -p 3000:3000 demo-clock-app:local
    ```
- **Port 3000 already in use:** Stop the process using it or map a different host port, e.g. `-p 3001:3000`.
- **Health check fails:** Inspect logs and hit the endpoint directly:
  ```bash
  docker logs clock-demo | tail -n +1
  curl -v http://localhost:3000/healthz
  ```

### Docker basics quick reference

```bash
# list running containers
docker ps

# list all containers (running and stopped)
docker ps -a

# list images
docker images

# list volumes and networks
docker volume ls
docker network ls

# show details
docker inspect clock-demo

# follow logs
docker logs -f clock-demo

# exec into a running container (sh)
docker exec -it clock-demo sh

# stop/start/remove a container
docker stop clock-demo
docker start clock-demo
docker rm -f clock-demo

# remove an image
docker rmi demo-clock-app:local

# prune unused resources (careful!)
docker container prune -f
docker image prune -f
docker volume prune -f
docker system prune -f
```

## Jenkins pipeline

This repo includes a `Jenkinsfile` that will:

- Build the Docker image
- Stop any previous `clock-demo` container
- Run the new container, exposing port 3000
- Perform a simple health check against `/healthz`

### Setup on Jenkins (simple demo)

1. Ensure Docker is installed on the Jenkins agent and the Jenkins user can run `docker`.
   - You can run this script as root on the Linux agent:
     ```bash
     curl -fsSL https://raw.githubusercontent.com/your-org/your-repo/main/scripts/setup-docker-jenkins.sh -o setup-docker-jenkins.sh
     sudo bash setup-docker-jenkins.sh
     ```
     Or, if running from this repo checkout on the agent:
     ```bash
     sudo ./scripts/setup-docker-jenkins.sh
     ```
2. Create a Multibranch or Pipeline job pointing at this repo.
3. Run the job. Once complete, the app should be reachable on the agent's port 3000.

### Auto-build on git push (GitHub)

1. In Jenkins: Manage Jenkins → Configure System → GitHub → Add GitHub Server. Add credentials/token and check “Manage hooks”. Install the “GitHub” and “GitHub Integration” plugins if missing.
2. In your repo settings on GitHub: Webhooks → Add webhook.
   - Payload URL: `http://<jenkins-host>:8080/github-webhook/`
   - Content type: `application/json`
   - Events: “Just the push event” (or “Let me select individual events” → Push)
3. Ensure your Jenkins job uses “Pipeline script from SCM” with this repo URL and that the `Jenkinsfile` contains a push trigger (already added):
   ```groovy
   triggers {
     githubPush()
   }
   ```
4. Push to the repository. Jenkins should receive the webhook and start a new build automatically.

> Note: For production, push images to a registry and deploy to a runtime (Kubernetes, ECS, etc.). This demo runs directly on the Jenkins agent for simplicity.

## Project structure

```
public/         # static assets (index.html, app.js, style.css)
src/server.js   # express server
Dockerfile
Jenkinsfile
```
