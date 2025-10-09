# motd

#### 目次

1. [概要](#overview)
2. [説明 - モジュールの機能とその有益性](#module-description)
3. [セットアップ - motdモジュール導入の基本](#setup)
    * [motdモジュールの導入](#beginning-with-the-motd-module)
4. [使用 - 設定オプションと追加機能](#usage)
5. [参考 - モジュールの機能と動作について](#reference)
6. [制約 - OS互換性など](#limitations)
7. [開発 - モジュール貢献についてのガイド](#development)

## モジュールの概要

motdモジュールでは、システムが表示する「本日のメッセージ(Message of The Day)」を構成できます。このモジュールには、デフォルトのメッセージテンプレートが含まれていますが、別のテンプレートや、静的な文字列を指定することもできます。

## セットアップ

### motdモジュールの導入

システムにmotdを構成するには、`include motd`と記述し、`motd`クラスをインクルードします。

## 使用

motdモジュールは、幅広いシステムにおいて本日のメッセージを構成します。本モジュールは、基本テンプレートファイルの内容から、`/etc/motd`、`/etc/issue`、および`/etc/issue.net` (POSIXシステムの場合)またはレジストリキー(Windowsシステムの場合)のいずれかを生成します。

デフォルトでは、モジュールは含まれているテンプレートを使用してmotdを生成しますが、別のテンプレートまたは静的な文字列を指定することもできます。たとえば、カスタムのテンプレートを使用するには、次のようにテンプレートパラメータを設定します。

```puppet
class { 'motd':
  template => 'mymodule/mytemplate.epp',
}
```

本日のメッセージとして文字列を指定するには、次のようにします。

```puppet
class { 'motd':
  content => "使用しないときは、ワークステーションをロックしてください\n",
}
```


## リファレンス
[REFERENCE.md](https://github.com/puppetlabs/puppetlabs-motd/blob/main/REFERENCE.md)を参照してください。

#### パブリッククラス

* `motd`: 本日のメッセージを構成します。

#### パラメータ

`motd`では、次のパラメータを使用できます。すべてのパラメータはオプションです。

##### `template`

カスタムのEPPテンプレートを指定します。テンプレートは`content`より優先されます。有効なオプション:  '/mymodule/mytemplate.epp'。デフォルト: 'undef'。

##### `content`

motdの内容として、静的な文字列を指定します。有効なオプション: "こんにちは!\n"や"使用しないときは、ワークステーションをロックしてください\n"などの文字列。デフォルト: 'undef'。

##### `dynamic_motd`

Debianシステムにおいて、動的なmotdの有効/無効を切り替えます。有効なオプション:  trueまたはfalse。デフォルト: true。

##### `issue_template`

処理するカスタムEPPテンプレートを指定し、 `/etc/issue`に保存します。テンプレートは`issue_content`より優先されます。有効なオプション:  '/mymodule/mytemplate.epp'。デフォルト: 'undef'。

##### `issue_content`

`/etc/issue`の内容として静的な文字列を指定します。有効なオプション: "こんにちは\n"や"使用しないときは、ワークステーションをロックしてください\n"などの文字列。デフォルト: 'undef'。

##### `issue_net_template`

処理するカスタムEPPテンプレートを指定して、`/etc/issue.net`に保存します。テンプレートは`issue_net_content`より優先されます。有効なオプション:  '/mymodule/mytemplate.epp'。デフォルト: 'undef'。

##### `issue_net_content`

`/etc/issue.net`の内容として静的な文字列を指定します。有効なオプション: "こんにちは\n"や"使用しないときは、ワークステーションをロックしてください\n"などの文字列。デフォルト: 'undef'。

## 制約

サポートされているオペレーティングシステムの一覧については、[metadata.json](https://github.com/puppetlabs/puppetlabs-motd/blob/main/metadata.json)を参照してください。

動的なmotdの無効化は、Debianのみでサポートされています。

### Windowsについての注意事項

Windowsシステムでは、motdモジュールは`HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system\legalnoticetext`および`HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system\legalnoticecaption`の内容を生成します。`legalnoticetext`レジストリキーは、Windowsシステムにログインする前に表示されます。

## 開発

Puppet Forgeに公開されているPuppet Labsモジュールはオープンプロジェクトのため、維持するにはコミュニティの貢献が不可欠です。Puppetは、現在私たちがアクセスできない無数のプラットフォームやハードウェア、ソフトウェア、デプロイ構成にも利用されることを目的としています。私たちの目標は、できる限り簡単に変更に貢献し、みなさまの環境で私たちのモジュールが機能できるようにすることです。最高の状態を維持するため、コントリビュータにはいくつかのガイドラインを守っていただく必要があります。詳細については、[モジュールコントリビューションガイド](https://docs.puppetlabs.com/forge/contributing.html)を参照してください。

## コントリビュータ

コントリビュータのリストは、[https://github.com/puppetlabs/puppetlabs-motd/graphs/contributors](https://github.com/puppetlabs/puppetlabs-motd/graphs/contributors)で見ることができます。
