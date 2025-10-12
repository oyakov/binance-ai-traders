Build faster: local Nexus + Docker/Maven caching

Prereqs
- Ensure Docker is running
- Windows PowerShell: set DOCKER_BUILDKIT per session when building

1) Start local Nexus (one-time)
```powershell
# from repo root
docker compose -f docker/docker-compose.nexus.yml up -d
# First login: http://localhost:8081
# Admin password is inside container: /nexus-data/admin.password
```

2) Pre-warm Maven deps via Nexus (optional but recommended)
```powershell
mvn -s maven-settings.xml -B -DskipTests dependency:go-offline
```

3) Fast local builds
```powershell
# Build a single module and its deps in parallel, skip tests
mvn -s maven-settings.xml -T 1C -DskipTests -B -pl binance-trader-macd -am package

# Offline when deps are cached
mvn -s maven-settings.xml -o -DskipTests package
```

4) Fast Docker builds (per module)
```powershell
$env:DOCKER_BUILDKIT=1
# Example: MACD trader
docker build -f binance-trader-macd/Dockerfile -t macd:dev .
# Data storage
docker build -f binance-data-storage/Dockerfile -t storage:dev .
# Data collection
docker build -f binance-data-collection/Dockerfile -t collection:dev .
```

Notes
- Dockerfiles copy POMs first and run `dependency:go-offline` with BuildKit cache to avoid re-downloading
- Maven settings route deps via Nexus; Confluent remains direct unless you add a Nexus proxy for it
- If Docker cannot reach `localhost`, `host.docker.internal` is substituted inside builder containers


