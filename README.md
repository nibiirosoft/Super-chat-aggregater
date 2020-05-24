# run.sh

特定のYouTubeチャンネルのすべての動画からスーパーチャット／スーパーステッカーを集計する。

## Installation

```bash
$ git clone https://github.com/nibiirosoft/super_chat_aggregater
```

## Usage

```bash
$ ./run.sh channel-id
```

## Input

・channel-id : チャンネルID

## Config

・config.txt : ダブ区切りの設定ファイル。税率(TAX), Youtube手数料率(FEE), 事務所マージン率(MARGIN), 他各種通貨の円換算のレートが保存されたリスト。

## Output

・watch.list.txt : 動画IDのリスト

・purchase.list.txt : [動画ID, 日時, ユーザー名, 通貨, 金額] がタブ区切りで保存されたリスト

・purchase.list2.txt : [動画ID, 日時, ユーザー名, 金額(円)] がタブ区切りで保存されたリスト

・purchase.summary.video.txt : [動画ID, 日時, 合計金額(円)] がタブ区切りで保存されたリスト

・purchase.summary.name.txt : [ユーザー名, 合計金額(円)] がタブ区切りで保存されたリスト

・purchase.summary.total.txt : [合計金額(円), 税金(円), Youtube手数料(円), 事務所マージン(円), 収入(円)] がタブ区切りで保存されたリスト
