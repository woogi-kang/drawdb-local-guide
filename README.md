# drawDB 로컬 설치 가이드 (npm → Docker → 시드 테이블)

[drawDB](https://github.com/drawdb-io/drawdb)는 브라우저에서 ERD를 그리고 SQL로 내보낼 수 있는 오픈소스 DB 설계 도구입니다.
이 레포는 **Windows / macOS** 에서 drawDB를

1. **npm** 으로 직접 실행해 보고
2. **Docker** (`nginx:latest` + `postgres:latest`) 로 띄운 다음
3. `localhost` 에 접속해 **쇼핑몰 시드 테이블을 SQL 파일로 불러오는 것**

까지 한 번에 따라 할 수 있도록 정리한 가이드입니다.

> 검증 환경 (2026-11-12, macOS): Node 26 / npm 11, Docker Desktop 29, `nginx:latest` = 1.31.8, `postgres:latest` = 18.6, drawDB `main` (602778410b)
> 스크린샷은 모두 위 환경의 로컬에서 직접 찍은 것입니다.

---

## 목차

- [0. 준비물 설치](#0-준비물-설치)
- [1. npm 으로 실행하기](#1-npm-으로-실행하기)
- [2. Docker 로 실행하기](#2-docker-로-실행하기)
- [3. 쇼핑몰 시드 테이블 불러오기](#3-쇼핑몰-시드-테이블-불러오기)
- [4. (선택) Postgres 에 들어간 시드 데이터 확인](#4-선택-postgres-에-들어간-시드-데이터-확인)
- [정리 / 삭제](#정리--삭제)
- [문제 해결](#문제-해결)

## 레포 구성

```
.
├── compose.yml                    # drawdb(nginx:latest) + postgres:latest
├── docker/
│   ├── Dockerfile                 # drawdb/dist 를 nginx:latest 에 복사
│   └── default.conf.template      # SPA 라우팅 + /config.js
├── seed/
│   ├── 01_shopping_schema.sql     # ★ drawDB 에 불러올 쇼핑몰 스키마 (6 테이블)
│   └── 02_shopping_data.sql       # Postgres 초기 데이터 (drawDB 에는 사용 안 함)
└── docs/images/                   # 가이드 스크린샷
```

---

## 0. 준비물 설치

| 도구 | 용도 | 권장 버전 |
| --- | --- | --- |
| Git | 소스 받기 | 최신 |
| Node.js (npm 포함) | 1단계 npm 실행 / 빌드 | **LTS (22 이상)** — vite 8 은 Node 20.19+ / 22.12+ 필요 |
| Docker Desktop | 2단계 컨테이너 실행 | 최신 |

### macOS

```bash
# Homebrew 가 없다면: https://brew.sh
brew install git node
brew install --cask docker   # 설치 후 Docker Desktop 앱을 한 번 실행
```

### Windows (PowerShell)

```powershell
winget install --id Git.Git -e
winget install --id OpenJS.NodeJS.LTS -e
winget install --id Docker.DockerDesktop -e   # WSL2 백엔드 사용, 설치 후 재부팅
```

> 설치 후 **새 터미널**을 열어야 PATH 가 반영됩니다.

설치 확인 (맥/윈도우 공통):

```bash
git --version
node -v
npm -v
docker --version
docker compose version
```

---

## 1. npm 으로 실행하기

### 1-1. 이 레포와 drawDB 소스 받기

drawDB 소스는 이 레포 안의 `drawdb/` 폴더로 클론합니다. (`.gitignore` 처리되어 있음)

```bash
git clone https://github.com/woogi-kang/drawdb-local-guide.git
cd drawdb-local-guide
git clone --depth 1 https://github.com/drawdb-io/drawdb.git drawdb
cd drawdb
```

### 1-2. 의존성 설치 & 개발 서버 실행

```bash
npm ci
npm run dev
```

터미널에 아래처럼 뜨면 성공입니다.

```
  VITE v8.x  ready in ...
  ➜  Local:   http://localhost:5173/
```

브라우저에서 **http://localhost:5173** 접속:

![npm dev 서버 첫 화면](docs/images/01-npm-dev-landing.png)

`Ctrl + C` 로 개발 서버를 끕니다.

### 1-3. 배포용 정적 파일 빌드

2단계 Docker 이미지는 여기서 만든 `drawdb/dist` 를 사용합니다.

```bash
npm run build
cd ..
```

`drawdb/dist/index.html` 이 생기면 완료입니다.

---

## 2. Docker 로 실행하기

> Docker Desktop 이 **실행 중**이어야 합니다. (메뉴바/트레이의 고래 아이콘)

레포 루트(`drawdb-local-guide/`)에서:

```bash
docker compose up -d --build
```

| 서비스 | 이미지 | 주소 |
| --- | --- | --- |
| drawdb | `nginx:latest` + drawDB 정적 파일 | http://localhost:8080 |
| postgres | `postgres:latest` | `localhost:15432` (user/pw/db = `shop`) |

상태 확인:

```bash
docker compose ps
```

```
NAME              IMAGE                 STATUS
drawdb            drawdb-local:latest   Up
drawdb-postgres   postgres:latest       Up (healthy)
```

### 왜 컨테이너 안에서 빌드하지 않나요?

drawDB(vite 8 / rolldown) 빌드는 순간적으로 메모리를 약 2GB 사용합니다.
Docker Desktop 기본 메모리(2GB)에서 컨테이너 안 빌드를 시도하면 `cannot allocate memory` (SIGKILL) 로 실패해서,
1단계에서 호스트가 빌드한 `dist` 를 nginx 이미지에 복사하는 방식으로 구성했습니다.

---

## 3. 쇼핑몰 시드 테이블 불러오기

### 3-1. 시드 SQL 다운로드

이미 레포를 클론했다면 `seed/01_shopping_schema.sql` 을 그대로 쓰면 됩니다.
파일만 받고 싶다면:

- 브라우저: [01_shopping_schema.sql 다운로드](https://raw.githubusercontent.com/woogi-kang/drawdb-local-guide/main/seed/01_shopping_schema.sql) (열리면 `Ctrl/Cmd + S` 로 저장)
- macOS 터미널:
  ```bash
  curl -LO https://raw.githubusercontent.com/woogi-kang/drawdb-local-guide/main/seed/01_shopping_schema.sql
  ```
- Windows PowerShell:
  ```powershell
  curl.exe -LO https://raw.githubusercontent.com/woogi-kang/drawdb-local-guide/main/seed/01_shopping_schema.sql
  ```

포함된 테이블 (PostgreSQL 문법):

| 테이블 | 설명 | 관계 |
| --- | --- | --- |
| `customers` | 회원 | |
| `categories` | 상품 카테고리 | |
| `products` | 상품 | `category_id → categories` |
| `orders` | 주문 | `customer_id → customers` |
| `order_items` | 주문 상세 | `order_id → orders`, `product_id → products` |
| `reviews` | 상품 리뷰 | `product_id → products`, `customer_id → customers` |

### 3-2. 에디터 열고 PostgreSQL 선택

**http://localhost:8080/editor** 로 접속하면 데이터베이스 선택 창이 뜹니다.
**PostgreSQL** 을 선택하고 **계속** 을 누릅니다.

![데이터베이스 선택](docs/images/02-select-postgres.png)

### 3-3. "SQL에서 가져오기" 선택

새 다이어그램 만들기 창에서 **SQL에서 가져오기** → **생성**.

![SQL에서 가져오기](docs/images/03-new-diagram-import-sql.png)

### 3-4. 시드 파일 업로드

**파일 업로드** 탭을 누르고 `01_shopping_schema.sql` 을 끌어다 놓거나 클릭해서 선택한 뒤 **가져오기**.
(SQL 내용을 복사해 **SQL 삽입** 탭에 붙여넣어도 됩니다.)

![시드 SQL 업로드](docs/images/04-upload-seed-sql.png)

### 3-5. 결과

테이블 6개, 관계 6개가 자동으로 그려집니다.

![불러온 쇼핑몰 ERD](docs/images/05-imported-diagram.png)

다이어그램은 브라우저(IndexedDB)에 자동 저장됩니다. 공유하려면 **파일 → 내보내기** 에서 JSON / SQL / PNG 등으로 내보내세요.

---

## 4. (선택) Postgres 에 들어간 시드 데이터 확인

`postgres` 컨테이너는 최초 기동 시 `seed/` 의 SQL 을 이름 순서대로 실행하므로, 같은 스키마에 샘플 데이터까지 들어가 있습니다.

```bash
docker exec -it drawdb-postgres psql -U shop -d shop -c "\dt"
docker exec -it drawdb-postgres psql -U shop -d shop -c "SELECT c.name, count(*) FROM orders o JOIN customers c ON c.id = o.customer_id GROUP BY 1;"
```

```
  name  | count
--------+-------
 이서연 |     1
 김민수 |     2
```

DBeaver / TablePlus 등으로 접속할 때: `localhost:15432`, DB `shop`, 사용자 `shop`, 비밀번호 `shop`.

> 반대로 실제 DB 의 스키마를 drawDB 로 옮기고 싶다면, `pg_dump --schema-only` 결과를 3-4 단계처럼 불러오면 됩니다.

---

## 정리 / 삭제

```bash
# 컨테이너 중지 (데이터 유지)
docker compose stop

# 컨테이너 + 네트워크 삭제 (Postgres 볼륨 유지)
docker compose down

# Postgres 볼륨까지 삭제 → 다음 기동 때 시드가 다시 들어감
docker compose down -v

# 빌드한 이미지까지 삭제
docker image rm drawdb-local:latest
```

---

## 문제 해결

| 증상 | 해결 |
| --- | --- |
| `port is already allocated` (8080 / 15432) | `compose.yml` 의 `ports` 왼쪽 숫자를 비어 있는 포트로 변경 |
| `COPY drawdb/dist ... not found` | 1-3 단계 `npm run build` 를 먼저 실행 |
| `npm ci` 에서 엔진/문법 오류 | `node -v` 확인 → Node LTS(22+) 로 업그레이드 |
| 시드 SQL 을 고쳤는데 Postgres 에 반영 안 됨 | init 스크립트는 **빈 볼륨일 때만** 실행 → `docker compose down -v` 후 다시 `up` |
| Windows 에서 Docker 가 안 뜸 | Docker Desktop 설정에서 WSL2 백엔드 활성화, BIOS 가상화(VT-x/AMD-V) 확인 |
| `postgres:latest` 업데이트 후 기동 실패 | 메이저 버전이 바뀌면 기존 볼륨과 호환되지 않음 → 백업 후 `docker compose down -v` |

## 라이선스

drawDB 는 [AGPL-3.0](https://github.com/drawdb-io/drawdb/blob/main/LICENSE) 입니다. 이 레포는 drawDB 소스를 포함하지 않고 설치 방법만 안내합니다.
