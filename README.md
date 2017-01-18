laravel 5.2 を使った開発環境
===========================

laravel の artisan などのコマンド実行に必要な最小限の作業環境。  
開発中の待ち時間が、小さくなるように、工夫している。

## laravelの高速セットアップ  
laravelは、依存プロジェクトが多くて、composer を使ったプロジェクトの作成や、
update などは、だいぶ時間がかかる。  
composerのリポジトリのレスポンスの遅延や、githubからのダウンロードの遅さが、原因の1つになっている。  

このDockerイメージには、あらかじめ、 composer create-project して作成したプロジェクトと、さらに、その作成過程で蓄えられた composerのキャッシュも、いっしょにパッケージされてある。  
これらは、外部のコンテナあるいはホストOSの開発用の作業ディレクトリをマウントしたあと、composerの実行を省略して、ディレクトリコピーだけで、composer実行後と同じ状態を復元するために使うことを想定している。

例えば、 /srv/app というボリュームをマウントして、そこに、composer create-project をする場合、次のディレクトリコピーで、実行後の状態が復元される。
```
cp -pr /root/larabel/ /srv/app/
cp -pr /root/.composer/ /home/nobita
chown -R nobita:nobita /home/nobita
chown -R nobita:nobita /srv/app
```

実際の開発では、コンテナ外のディレクトリをマウントして、そこに、プロジェクトを作成するわけだが、composer create-project するのではなく、作成済のディレクトリをコピーすることで、create-projectしたのと同じ状態にする。  
これで、何度でも、躊躇なく、プロジェクトを作り直すことができる。  
また、 ~/.composer のキャッシュも残しておくことで、開発着手時点でキャッシュが効いた状態を作ることができる。  
このキャッシュディレクトリもデータコンテナ等でマウントして、コピーして、キャッシュを永続化するとよいと思う。

## nodejs
nodejsもインストールしたあと、 laravel elixir の ackage.json で npm install をして
node_modules を作成済の状態にしてある。  
こっちも同じく、データコンテナでマウントして、node_modules を コピーすることで、npm install しなくてよいので、すばやく、環境の準備が整う。

## 開発用のユーザー
composer や artisan などを実行するときのユーザーを作成してある。  
コンテナ内での実行は、このユーザーで、行うとよいかと思う。  
ユーザー: nobita (uid=1000)

## Dockerfile のメンテ
Dockerfileは、開発中に何度か修正するかもしれないが、そのときに、composer をうごかしたのでは、それに時間がとられてしまうので、あえて、RUN を細かく、分割して、build が、すばやく終わるようにしている。  
このDockerイメージは、本番で運用するものではないので、層が重なったところで、あまり問題にならない。
