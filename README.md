特定のYouTubeチャンネルのすべてのライブ配信アーカイブ動画からスーパーチャット／スーパーステッカーを集計する。

年別、月別、動画別、ユーザー別、全体での合計金額を計算する。
為替レートに応じて円換算で出力する。
Youtube API非使用なのでBash/Python3の実行環境があればチャンネルIDを指定するだけでOK。

※注意：コメント非表示の場合は集計不可。動画がクリッピングされている場合はコメントが非表示になるので集計不可。コメントがアーカイブに収録されていない場合は集計不可。

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

[channel-id]_[チャンネル名]のフォルダを作成し、その下に次のファイルを生成する。

- watch.list.txt : 動画IDのリスト

- purchase.list.txt : [動画ID, 日時, ユーザー名, 通貨, 金額, コメント] がタブ区切りで保存されたリスト

- purchase.list2.txt : [動画ID, 日時, ユーザー名, 金額(円), コメント] がタブ区切りで保存されたリスト ![](https://user-images.githubusercontent.com/65806595/83334234-0ea09380-a2e0-11ea-9311-cc0b3f987226.jpg)

- purchase.summary.video.txt : [動画ID, 日時, 合計金額(円)] がタブ区切りで保存されたリスト ![](https://user-images.githubusercontent.com/65806595/82765027-44f89180-9e4e-11ea-91ca-8a20424213a9.jpg)

- purchase.summary.month.txt : [年-月, 合計金額(円), 合計金額(万円)] がタブ区切りで保存されたリスト ![](https://user-images.githubusercontent.com/65806595/83333075-b5cdfc80-a2d9-11ea-9f0b-f5c85310ed00.jpg)

- purchase.summary.year.txt : [年, 合計金額(円), 合計金額(万円)] がタブ区切りで保存されたリスト ![](https://user-images.githubusercontent.com/65806595/82816728-a06e6200-9ed6-11ea-9e4e-2306fb082263.jpg)

- purchase.summary.name.txt : [ユーザー名, 合計金額(円), 合計金額(万円)] がタブ区切りで保存されたリスト ![](https://user-images.githubusercontent.com/65806595/82764935-9f452280-9e4d-11ea-86f0-10f5c6a41c5b.jpg)

- purchase.summary.total.txt : [合計金額(円), 税金(円), Youtube手数料(円), 事務所マージン(円), 収入(円)] がタブ区切りで保存されたリスト ![](https://user-images.githubusercontent.com/65806595/82764794-8a1bc400-9e4c-11ea-9411-0b63a264cb49.jpg)

- purchase.summary.other.txt : [通貨, 金額] がタブ区切りで保存されたリスト。config.txtで定義されていない通貨がリストアップされる
