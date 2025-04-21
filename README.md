# ADALM2000 Docker Environment

ADALM2000をDockerコンテナから制御するための開発環境を提供するDockerfileです。

## 概要

このプロジェクトは、Analog DevicesのADALM2000をDockerコンテナから制御するための環境を構築します。libiioとlibm2kライブラリを使用して、ADALM2000の機能にアクセスできます。

## 必要条件

- Docker
- Docker Compose
- ADALM2000ハードウェア
- Ethernet接続（ADALM2000接続用）
- ADALM2000のIPアドレス設定

## インストール方法

1. リポジトリのクローン:
```bash
git clone https://github.com/mochimaki/m2k_Dockerfile.git
cd m2k_Dockerfile
```

2. Dockerイメージのビルド:
```bash
docker build -t adalm2000-env .
```

または、Docker Composeを使用してビルドと起動を行う:
```bash
docker-compose up -d
```

## 使用方法

### 基本的な使用方法

1. コンテナの起動:
```bash
docker-compose up -d
```

2. コンテナへのログイン:
```bash
docker exec -it m2k_github-adalm2000-1 bash
```

3. テストディレクトリへの移動とスクリプトの実行:
```bash
cd /home/m2k/test
python3 analog_test.py
```

### サンプルプログラムの説明

`test/analog_test.py`は以下の機能を提供します：

```python
import libm2k
import numpy as np

def main():
    # ADALM2000の初期化（IPアドレスを指定）
    ctx = libm2k.m2kOpen("ip:192.168.2.1")  # ADALM2000のIPアドレスを指定
    if ctx is None:
        print("ADALM2000が見つかりません")
        return

    try:
        # アナログ入力の設定
        ain = ctx.getAnalogIn()
        ain.setSampleRate(100000)
        ain.setRange(libm2k.ANALOG_IN_CHANNEL_1, -10, 10)

        # データの取得
        data = ain.getSamples(1000)
        print("取得したデータ:", data)

    finally:
        # リソースの解放
        ctx.close()

if __name__ == "__main__":
    main()
```

### 環境設定

1. 必要なPythonパッケージのインストール:
```bash
cd /home/m2k/test
pip install -r requirements.txt
```

2. 仮想環境の確認:
```bash
which python3  # /home/m2k/venv/m2k/bin/python3 を表示するはず
```

### バージョン情報

コンテナ起動時に、以下のバージョン情報が`version_info`ディレクトリに自動的に出力されます：

1. `build_versions.txt`: ビルド時の各コンポーネントのバージョン情報
   - Ubuntu, Python, CMake, GCC, SWIGなどのバージョン
   - libiio, libm2kなどの依存ライブラリのバージョン
   - ビルド日時

2. `installed_packages.txt`: Pythonの仮想環境にインストールされているパッケージのリスト
   - libm2k, numpy, setuptoolsなどのパッケージバージョン

これらのファイルは、環境の再現性を確保し、トラブルシューティングを支援するために使用できます。

### 注意事項
- ADALM2000はEthernet経由で接続する必要があります
- コンテナ起動時は`--network host`オプションを使用してホストのネットワークを使用
- ADALM2000のIPアドレスは適切に設定されている必要があります
- USBポートはホストPCで管理されるため、コンテナからは直接アクセスできません

## 機能

- libiioとlibm2kライブラリの統合
- Python開発環境
- USBデバイスへのアクセス
- アナログ入力/出力制御
- デジタル入力/出力制御

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE.md)ファイルを参照してください。

### 依存ライブラリのライセンス

このプロジェクトは以下のライブラリに依存しています：

- libiio: GNU Lesser General Public License Version 2.1
  - ライセンス全文: [COPYING.txt](https://github.com/analogdevicesinc/libiio/blob/main/COPYING.txt)
- libm2k: GNU General Public License v2
  - ライセンス全文: [LICENSE](https://github.com/analogdevicesinc/libm2k/blob/main/LICENSE)

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

3. コンテナが起動しない場合:
   - Docker Composeのログを確認: `docker-compose logs`
   - コンテナの状態を確認: `docker-compose ps`

## コントリビューション

1. このリポジトリをフォーク
2. 新しいブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 作者

mochimaki

## 謝辞

- Analog Devices Inc. - ADALM2000ハードウェアとライブラリの提供
- libiioとlibm2kの開発チーム