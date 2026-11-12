# ---------------------------------------------------------
# drawDB 정적 파일(drawdb/dist)을 nginx:latest 로 서빙
#
# README 2단계에서 `npm run build` 로 만든 dist 를 그대로 복사합니다.
# 컨테이너 안에서 다시 빌드하지 않는 이유:
#   drawDB(vite 8 / rolldown) 빌드는 순간 메모리를 ~2GB 쓰기 때문에
#   Docker Desktop 기본 메모리(2GB)에서는 OOM 으로 실패합니다.
# ---------------------------------------------------------
FROM nginx:latest
COPY drawdb/dist /usr/share/nginx/html
# templates/*.template 은 컨테이너 시작 시 envsubst 로 /etc/nginx/conf.d 에 생성됨
COPY docker/default.conf.template /etc/nginx/templates/default.conf.template
ENV VITE_BACKEND_URL="" VITE_GIST_BACKEND_URL=""
EXPOSE 80
