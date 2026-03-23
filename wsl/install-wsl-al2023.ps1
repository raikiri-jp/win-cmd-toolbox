# ============================================================
# install-wsl-al2023.ps1
#
# 使い方: ターミナルを管理者で開き、以下のコマンドを実行します。
#   .\install-wsl-al2023.ps1 -WslHome C:\wsl
#   .\install-wsl-al2023.ps1 -WslHome C:\wsl -DistroName AL2023
# ============================================================

param(
  [Parameter(Mandatory = $true)]
  [string]$WslHome = 'C:\wsl',
  [string]$DistroName = 'AL2023'
)

# WslHomeの末尾に\がなければ追加
if (-not ($WslHome.EndsWith('\') -or $WslHome.EndsWith('/'))) {
  $WslHome = "$WslHome\"
}

# ダウンロード先とWSLインポート先のパスを定義
$downloadDir = "${WslHome}_downloads\"
$wslDistro = "${WslHome}${DistroName}\"
$baseUrl = 'https://cdn.amazonlinux.com/al2023/os-images/latest/container/'

# 情報表示
Write-Host "WslHome    : $WslHome"
Write-Host "DistroName : $DistroName"
Write-Host ''

# 最新のイメージファイル名を取得
$fileName = ((Invoke-WebRequest $baseUrl -UseBasicParsing).Links.href `
  | Where-Object { $_ -match 'al2023-container-.*x86_64\.tar\.xz$' } `
  | Select-Object -First 1)

# イメージをダウンロード
mkdir $downloadDir -Force | Out-Null
Write-Host "ダウンロード: $fileName"
Invoke-WebRequest -Uri "$baseUrl$fileName" -OutFile "$downloadDir$fileName"

# WSLにインポート
mkdir $wslDistro -Force | Out-Null
Write-Host "インポート: $DistroName"
wsl --import $DistroName $wslDistro "$downloadDir$fileName"

# 基本的なパッケージインストールとsystemd有効化
$commandsA = @(
  'dnf update -y',
  'dnf install -y systemd util-linux iptables libseccomp container-selinux xz dnf-plugins-core',
  @'
cat << 'EOF' > /etc/wsl.conf
[boot]
systemd=true
EOF
'@
) -Join ' && '
Write-Host "RUN: $commandsA"
wsl -d $DistroName -- bash -c ('set -e; ' + $commandsA)
if ($LASTEXITCODE -ne 0) {
  Write-Host 'エラーが発生しました。処理を中断します。'
  exit 1
}

# WSLを再起動してsystemdを有効化
wsl --shutdown

# よく使うコマンドをインストール
$commandsB = @(
  'dnf install -y which findutils vim git wget tar python3'
) -Join ' && '
Write-Host "RUN: $commandsB"
wsl -d $DistroName -- bash -c ('set -e; ' + $commandsB)
if ($LASTEXITCODE -ne 0) {
  Write-Host 'エラーが発生しました。処理を中断します。'
  exit 1
}

# Dockerや開発に必要なパッケージをインストール
# Ref. https://docs.docker.com/engine/install/rhel/
$commandsC = @(
  'dnf remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman runc',
  'dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo',
  # RHELのバージョンを9に固定
  'cat /etc/yum.repos.d/docker-ce.repo',
  'sed -i ''s/\$releasever/9/g'' /etc/yum.repos.d/docker-ce.repo',
  'dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin',
  'systemctl enable --now docker'
) -Join ' && '
Write-Host "RUN: $commandsC"
wsl -d $DistroName -- bash -c ('set -e; ' + $commandsC)
if ($LASTEXITCODE -ne 0) {
  Write-Host 'エラーが発生しました。処理を中断します。'
  exit 1
}

wsl -d $DistroName -- bash -c 'dnf update -y'

# ダウンロードしたイメージと一時フォルダを削除
Remove-Item -Path "$downloadDir$fileName" -Force
Remove-Item -Path "$downloadDir" -Force

# 完了
Write-Host @"
インストール完了: $DistroName
=========================================================================
$DistroName を起動するコマンド:
> wsl -d $DistroName
-------------------------------------------------------------------------
$DistroName を停止するコマンド:
> wsl -t $DistroName
-------------------------------------------------------------------------
$DistroName を完全に削除するコマンド:
> wsl --unregister $DistroName
-------------------------------------------------------------------------
hello-worldイメージを実行して、インストールが成功していることを確認:
# docker run hello-world
=========================================================================
"@
