
# zfs_core

#### 目次

1. [説明](#description)
2. [使用 - 設定オプションと追加機能](#usage)
3. [参考 - モジュールの機能と動作について](#reference)
4. [制約 - OS互換性など](#limitations)
5. [開発 - モジュール貢献についてのガイド](#development)

<a id="description"></a>
## 説明

zfs_coreモジュールは、zfsリソースおよびzpoolリソースの両方を管理するために使用します。このモジュールはSolarisマシンでしかテストされていませんが、zfsまたはzpoolリソースのあるすべてのマシンで機能するはずです。

<a id="usage"></a>
## 使用

ディスク`/ztstpool/dsk`を使用するzpoolリソースを`tstpool`という名前で作成するには、以下のコードを使用します。
```
zpool { 'tstpool':
  ensure => present,
  disk => '/ztstpool/dsk',
}
```
上で作成したプールに基づくzfsを作成するには、以下のコードを使用します。
```
zfs { 'tstpool/tstfs':
  ensure => present,
}
```

<a id="reference"></a>
## リファレンス

`zfs_core`および`zpool_core`モジュールについては、REFERENCE.md文書を参照してください。

このモジュールは、Puppet Stringsを用いて文書化されています。

Stringsの仕組みの簡単な概要については、Puppet Stringsに関する[こちらのブログ記事](https://puppet.com/blog/using-puppet-strings-generate-great-documentation-puppet-modules)または[README.md](https://github.com/puppetlabs/puppet-strings/blob/master/README.md)を参照してください。

文書をローカルで作成するには、以下のコマンドを実行します。
```
bundle install
bundle exec puppet strings generate ./lib/**/*.rb
```
このコマンドにより、閲覧可能な`\_index.html`ファイルが`doc`ディレクトリに作成されます。ここで利用可能なリファレンスはすべて、コードベースに埋め込まれたYARD形式のコメントから生成されます。このモジュールに関して何らかの開発をする場合は、影響を受ける文書も更新する必要があります。

<a id="limitations"></a>
## 制約

このモジュールは、zfsおよびzpoolの両方を使用できるプラットフォームでのみ使用可能です。

<a id="development"></a>
## 開発

Puppet ForgeのPuppet Labsモジュールは、オープンプロジェクトです。プロジェクトをさらに発展させるには、コミュニティへの貢献が不可欠です。Puppetが役立つ可能性のある膨大な数のプラットフォーム、無数のハードウェア、ソフトウェア、デプロイメント構成に我々がアクセスすることはできません。

弊社は、できるだけ変更に貢献しやすくして、弊社のモジュールがユーザの環境で機能する状態を維持したいと考えています。弊社では、状況を把握できるよう、貢献者に従っていただくべきいくつかのガイドラインを設けています。

詳細については、[モジュール貢献ガイド](https://docs.puppetlabs.com/forge/contributing.html)を参照してください。
