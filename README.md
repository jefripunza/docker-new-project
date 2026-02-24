# docker-new-project

Development Docker image bundled with **FrankenPHP (Caddy)** and **code-server** (VS Code in the browser). Supports automatic initialization of **CodeIgniter 4** or **Laravel** projects.

## Included

- **FrankenPHP + Caddy** serves the app on port **80** (HTTP)
- **code-server** for editing source code via browser on port **8080**
- **Auto-initialization** for CodeIgniter 4 or Laravel (optional)

## Quick Start

### Start with CodeIgniter 4

```bash
docker run -d --name ci4 \
  -p 81:80 \
  -p 8081:8080 \
  -e INIT_FRAMEWORK=ci4 \
  -e CODE_SERVER_PASSWORD=rahasia \
  jefriherditriyanto/docker-new-project
```

### Start with Laravel

```bash
docker run -d --name laravel \
  -p 81:80 \
  -p 8081:8080 \
  -e INIT_FRAMEWORK=laravel \
  -e CODE_SERVER_PASSWORD=rahasia \
  jefriherditriyanto/docker-new-project
```

### Start with existing project

```bash
docker run -d --name myapp \
  -p 81:80 \
  -p 8081:8080 \
  -e CODE_SERVER_PASSWORD=rahasia \
  -v "$(pwd)/my-project:/app" \
  jefriherditriyanto/docker-new-project
```

Access:

- **App (CI4)**: `http://localhost:81`
- **code-server**: `http://localhost:8081`

## Ports

- **80/tcp**: Web app (FrankenPHP/Caddy)
- **8080/tcp**: code-server

## Environment Variables

- `INIT_FRAMEWORK` (optional) framework to initialize if `/app` is empty. Supported values:
  - `ci4` or `codeigniter4` - Install CodeIgniter 4
  - `laravel` or `laravel12` - Install Laravel 12
  - Leave empty or unset to skip auto-initialization
- `CODE_SERVER_PASSWORD` (default: `admin123`) password for code-server login
- `CODE_SERVER_PORT` (default: `8080`) code-server internal port
- `CODE_SERVER_HOST` (default: `0.0.0.0`) code-server internal bind address
- `CODE_SERVER_AUTH` (default: `password`) code-server auth mode
- `APP_DIR` (default: `/app`) project folder opened by code-server

## Persisting Your Project (Recommended)

To keep your source code changes on the host (so they are not lost when the container is removed), mount your project into `/app`.

```bash
mkdir -p ./app

docker run -d --name ci4 \
  -p 81:80 \
  -p 8081:8080 \
  -e CODE_SERVER_PASSWORD=rahasia \
  -v "$(pwd)/app:/app" \
  jefriherditriyanto/docker-new-project
```

Notes:

- Make sure the `writable/` folder is writable by the container. If you run into permission issues, run `chmod -R 775 ./app/writable`.

## Docker Compose

Example `docker-compose.yml` with CodeIgniter 4:

```yaml
services:
  ci4:
    image: jefriherditriyanto/docker-new-project
    container_name: ci4
    ports:
      - "81:80"
      - "8081:8080"
    environment:
      INIT_FRAMEWORK: ci4
      CODE_SERVER_PASSWORD: rahasia
    volumes:
      - ./app:/app
```

Example with existing project (no auto-init):

```yaml
services:
  myapp:
    image: jefriherditriyanto/docker-new-project
    container_name: myapp
    ports:
      - "81:80"
      - "8081:8080"
    environment:
      CODE_SERVER_PASSWORD: rahasia
    volumes:
      - ./my-existing-project:/app
```

Run:

```bash
docker compose up -d
```

## Build Locally

```bash
docker build -t docker-new-project .
docker run -d --name ci4 -p 81:80 -p 8081:8080 docker-new-project
```

## Security Notes

- This image is intended for **development**.
- `code-server` will expose the editor based on your port mappings. Use a strong password, and if you deploy on a public server, place it behind a reverse proxy and/or VPN.
