#!/bin/sh

echo "🔧 Config.xcconfig 파일 생성 시작..."

CONFIG_PATH="$CI_PRIMARY_REPOSITORY_PATH/Forday/Source/Data/Config/Config.xcconfig"

mkdir -p "$(dirname "$CONFIG_PATH")"

cat <<EOF > "$CONFIG_PATH"
KAKAO_APP_KEY = $KAKAO_APP_KEY
BASE_URL = https:/\$()/$BASE_URL
EOF

echo "✅ Config.xcconfig 파일 생성 완료: $CONFIG_PATH"
cat "$CONFIG_PATH"
