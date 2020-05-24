特定のYouTubeチャンネルのすべてのライブ配信アーカイブ動画からスーパーチャット／スーパーステッカーを集計し合計を計算する。

## Installation

```bash
$ git clone https://github.com/nibiirosoft/Super-chat-aggregater
```

## Usage

```bash
$ ./run.sh channel-id
```

## Input

- channel-id : チャンネルID

## Config

- config.txt : ダブ区切りの設定ファイル。税率(TAX), Youtube手数料率(FEE), 事務所マージン率(MARGIN), 他各種通貨の円換算のレートが保存されたリスト。

## Output

- watch.list.txt : 動画IDのリスト

- purchase.list.txt : [動画ID, 日時, ユーザー名, 通貨, 金額, コメント] がタブ区切りで保存されたリスト

- purchase.list2.txt : [動画ID, 日時, ユーザー名, 金額(円), コメント] がタブ区切りで保存されたリスト ![](https://user-images.githubusercontent.com/65806595/82765164-41193f00-9e4f-11ea-9d1e-a2a8c5df6106.jpg)

- purchase.summary.video.txt : [動画ID, 日時, 合計金額(円)] がタブ区切りで保存されたリスト ![](https://user-images.githubusercontent.com/65806595/82765027-44f89180-9e4e-11ea-91ca-8a20424213a9.jpg)

- purchase.summary.name.txt : [ユーザー名, 合計金額(円), 合計金額(万円)] がタブ区切りで保存されたリスト ![](https://user-images.githubusercontent.com/65806595/82764935-9f452280-9e4d-11ea-86f0-10f5c6a41c5b.jpg)

- purchase.summary.total.txt : [合計金額(円), 税金(円), Youtube手数料(円), 事務所マージン(円), 収入(円)] がタブ区切りで保存されたリスト ![](https://user-images.githubusercontent.com/65806595/82764794-8a1bc400-9e4c-11ea-9411-0b63a264cb49.jpg)

- purchase.summary.other.txt : [通貨, 金額] がタブ区切りで保存されたリスト。config.txtで定義されていない通貨がリストアップされる
