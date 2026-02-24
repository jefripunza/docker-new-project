# docker-new-project-codeigniter

Development Docker image for **CodeIgniter 4** bundled with **FrankenPHP (Caddy)** and **code-server** (VS Code in the browser).

## Included

- **CodeIgniter 4 App Starter** is pre-installed in `/app`
- **FrankenPHP + Caddy** serves the app on port **80** (HTTP)
- **code-server** for editing source code via browser on port **8080**

## Quick Start

Run the container:

```bash
docker run -d --name ci4 \
  -p 81:80 \
  -p 8081:8080 \
  -e CODE_SERVER_PASSWORD=rahasia \
  jefriherditriyanto/docker-new-project-codeigniter
```

Access:

- **App (CI4)**: `http://localhost:81`
- **code-server**: `http://localhost:8081`

## Ports

- **80/tcp**: Web app (FrankenPHP/Caddy)
- **8080/tcp**: code-server

## Environment Variables

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
  jefriherditriyanto/docker-new-project-codeigniter
```

Notes:

- Make sure the `writable/` folder is writable by the container. If you run into permission issues, run `chmod -R 775 ./app/writable`.

## Docker Compose

Example `docker-compose.yml`:

```yaml
services:
  ci4:
    image: jefriherditriyanto/docker-new-project-codeigniter
    container_name: ci4
    ports:
      - "81:80"
      - "8081:8080"
    environment:
      CODE_SERVER_PASSWORD: rahasia
    volumes:
      - ./app:/app
```

Run:

```bash
docker compose up -d
```

## Build Locally

```bash
docker build -t docker-new-project-codeigniter .
docker run -d --name ci4 -p 81:80 -p 8081:8080 docker-new-project-codeigniter
```

## Security Notes

- This image is intended for **development**.
- `code-server` will expose the editor based on your port mappings. Use a strong password, and if you deploy on a public server, place it behind a reverse proxy and/or VPN.
