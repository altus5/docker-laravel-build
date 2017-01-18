FROM alpine:3.4

ENV DEVELOP_USER=nobita

COPY package.json /tmp/package.json

RUN \
  # developユーザー作成
  adduser -D -u 1000 $DEVELOP_USER && \
  echo "$DEVELOP_USER ALL=NOPASSWD:ALL" >> /etc/sudoers && \
  # phpなどのパッケージのインストール
  apk add --no-cache \
  php5 php5-json php5-phar php5-openssl php5-dom php5-xml php5-zlib php5-pdo \
  nodejs git curl bash jq && \
  # composerのインストール
  curl -sS https://getcomposer.org/installer | php && \
  mv composer.phar /usr/local/bin/composer
  
RUN \
  # laravel
  cd /home/$DEVELOP_USER && \
  composer create-project --prefer-dist "laravel/laravel=5.2.*" -vvv
  # composer の cache は、 /root/.composer に作成されたが、
  # そのまま、残しておく
  
RUN \
  # npm 
  apk add --no-cache --virtual .builddeps python build-base && \
  npm install --global gulp@3.9 && \
  cd /home/$DEVELOP_USER/laravel && \
  mv /tmp/package.json . && \
  npm install && \
  apk del .builddeps
  
RUN \
  chown -R $DEVELOP_USER:$DEVELOP_USER /home/$DEVELOP_USER/

CMD ["php"]
