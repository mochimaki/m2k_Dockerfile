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