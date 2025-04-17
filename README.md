# ADALM2000 Docker Environment

ADALM2000をDockerコンテナから制御するための開発環境を提供するDockerfileです。

## 概要

このプロジェクトは、Analog DevicesのADALM2000をDockerコンテナから制御するための環境を構築します。libiioとlibm2kライブラリを使用して、ADALM2000の機能にアクセスできます。

## 必要条件

- Docker
- ADALM2000ハードウェア
- USBポート（ADALM2000接続用）

## インストール方法

1. リポジトリのクローン:
```bash
git clone https://github.com/[あなたのGitHubアカウント名]/[リポジトリ名].git
cd [リポジトリ名]
```

2. Dockerイメージのビルド:
```bash
docker build -t adalm2000-env .
```

## 使用方法

1. コンテナの起動:
```bash
docker run -it --privileged \
  --device=/dev/bus/usb:/dev/bus/usb \
  adalm2000-env
```

2. Pythonでの使用例:
```python
import libm2k
import numpy as np

# ADALM2000の初期化
ctx = libm2k.m2kOpen()
if ctx is None:
    print("ADALM2000が見つかりません")
    exit(1)

# アナログ入力の設定
ain = ctx.getAnalogIn()
ain.setSampleRate(100000)
ain.setRange(libm2k.ANALOG_IN_CHANNEL_1, -10, 10)

# データの取得
data = ain.getSamples(1000)
print(data)
```

## 機能

- libiioとlibm2kライブラリの統合
- Python開発環境
- USBデバイスへのアクセス
- アナログ入力/出力制御
- デジタル入力/出力制御

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

### 依存ライブラリのライセンス

このプロジェクトは以下のライブラリに依存しています：

- libiio: GNU Lesser General Public License v2以降
- libm2k: GNU General Public License v2以降

各ライブラリのライセンス全文は以下のファイルを参照してください：
- [COPYING.LGPL](COPYING.LGPL)
- [COPYING.GPL](COPYING.GPL)

### 商用利用に関する注意

libiioおよびlibm2kの商用利用には、Analog Devicesとの別途ライセンス契約が必要な場合があります。
詳細は[Analog Devicesのライセンス条項](https://www.analog.com/jp/lp/001/analog_devices_software_license_agreement.html)を参照してください。

## トラブルシューティング

1. USBデバイスが認識されない場合:
   - ホストマシンで`lsusb`コマンドを実行し、ADALM2000が認識されているか確認
   - Dockerコンテナに`--privileged`フラグが付いているか確認
   - USBデバイスのパーミッションを確認

2. ライブラリのインポートエラー:
   - Python環境が正しく設定されているか確認
   - 必要なライブラリがインストールされているか確認

## コントリビューション

1. このリポジトリをフォーク
2. 新しいブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 作者

[あなたのGitHubアカウント名]

## 謝辞

- Analog Devices Inc. - ADALM2000ハードウェアとライブラリの提供
- libiioとlibm2kの開発チーム