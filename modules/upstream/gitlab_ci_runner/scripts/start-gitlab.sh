#!/bin/bash

docker run --detach --rm \
  --name gitlab \
  --hostname gitlab \
  -e GITLAB_ROOT_PASSWORD=voxpupulirocks \
  --publish 80:80 \
  gitlab/gitlab-ce

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gitlab > ~/GITLAB_IP

until wget -t 1 'http://localhost:80' -O /dev/null -q; do
  docker logs gitlab --tail 10
  sleep 3
done

OUTPUT="$(echo 'puts "INSTANCE TOKEN: #{Gitlab::CurrentSettings.current_application_settings.runners_registration_token}"' | docker exec -i gitlab gitlab-rails console)"
INSTANCE_TOKEN="$(echo "$OUTPUT" | awk '/^INSTANCE TOKEN:/ {print $NF}')"
echo "${INSTANCE_TOKEN}" > ~/INSTANCE_TOKEN
