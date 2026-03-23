# win-cmd-toolbox

Windows 環境で使えるバッチコマンド集です。主に Windows 11 向けの設定変更やユーティリティスクリプトをまとめています。右クリックメニューの切り替えなど、GUI では手間な操作をワンタッチで行える `.cmd` ファイルを収録しています。

## 📁 ディレクトリ構成

- net/
  - check-ip.cmd
- win/
  - context-classic.cmd
  - context-default.cmd
  - explorer-launchto-home.cmd
  - explorer-launchto-pc.cmd
  - explorer-settings-reset.cmd
  - explorer-settings.cmd
  - restart-explorer.cmd
  - setup.cmd
- wsl/
  - install-wsl-al2023.ps1

## 🛠️ 各スクリプトの説明

### 🧰 `win/context-classic.cmd`

Windows 11 のエクスプローラーで右クリックしたときのメニューを、Windows 10 スタイルのクラシック表示に変更します。

<!-- 実行ユーザのレジストリを更新します。 -->

### 🧰 `win/context-default.cmd`

`win/context-classic.cmd` の変更を元に戻し、Windows 11 標準の右クリックメニューに復元します。

<!-- 実行ユーザのレジストリを更新します。 -->

### 🧰 `win/explorer-launchto-pc.cmd`

エクスプローラーを開いたときの既定の表示を「PC」（マイコンピュータ）に変更します。

### 🧰 `win/explorer-launchto-home.cmd`

エクスプローラーの初期表示を「ホーム」に戻します（Windows のデフォルト動作）。

### 🧰 `win/explorer-settings.cmd`

エクスプローラーの表示設定を次の通り調整します。

- 隠しファイルを表示
- 拡張子を表示

<!-- 実行ユーザのレジストリを更新します。 -->

### 🧰 `win/explorer-settings-reset.cmd`

エクスプローラーの表示設定を次の通り調整します。

- 隠しファイルを非表示
- 拡張子を非表示

<!-- 実行ユーザのレジストリを更新します。 -->

### 🧰 `win/restart-explorer.cmd`

Explorer を再起動します。
設定変更を即時反映させるために使用します。

他のスクリプトから `call "%~dp0restart-explorer.cmd"` のように呼び出して使用します。

### 🧰 `win/setup.cmd`

以下の設定をまとめて適用します。

- クラシックコンテキストメニューへの切り替え
- エクスプローラーの初期表示を「PC」に変更
- 拡張子表示・隠しファイル表示を有効化

#### 🧰 `win/setup.cmd` が内部的に呼び出しているスクリプト

- `win/context-classic.cmd`
- `win/explorer-launchto-pc.cmd`
- `win/explorer-settings.cmd`
- `win/restart-explorer.cmd`

### 🧰 `net/check-ip.cmd`

ローカルIPアドレスとグローバルIPアドレスを表示します。

- グローバルIP取得にはインターネット接続が必要です。

### 🧰 `wsl/install-wsl-no-distribution.ps1`

Linux を含めずに WSL2 をインストールします。
ゲストOSのインストール場所を指定したい場合に使用します。

### 🧰 `wsl/install-wsl-al2023.ps1`

WSL に Amazon Linux 2023 をインストールします。

```ps1
cd wsl
.\install-wsl-no-distribution.ps1
.\install-wsl-al2023.ps1 -WslHome C:\wsl
wsl -d AL2023
```

## 🔰 SmartScreen による起動ブロックの回避方法

ZIPでダウンロードしてエクスプローラーからコマンドを実行しようとすると Window Defender SmartScreen により起動がブロックされます。
ZIPファイルのプロパティを開き、「セキュリティ」の「許可する」にチェックを入れてからZIPファイルを展開することで、コマンド起動はブロックされなくなります。

![ZIPを展開する前にセキュリティを許可する](./_document/image/windows-protection-1.png)

もし、コマンドを実行して下記の青い画面が表示された場合は、「詳細情報」をクリックすることでも実行できます。

![Window Defender SmartScreen により起動がブロックされる](./_document/image/windows-protection-2.png)
![詳細情報をクリックすると実行ボタンが表示される](./_document/image/windows-protection-3.png)
