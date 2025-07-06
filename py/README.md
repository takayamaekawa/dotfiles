# Discord Chat to XLSX Exporter

DiscordチャンネルのメッセージをExcelファイル（XLSX）にエクスポートするPythonスクリプトです。

## 機能

- 📊 **複数チャンネル対応**: 複数のチャンネルを選択して一度にエクスポート
- 🎯 **インタラクティブ選択**: ターミナルで使いやすいチャンネル選択UI
- ⚡ **メッセージ数推定**: 処理前に推定メッセージ数を表示し、大量データの警告
- 📈 **豊富な統計情報**: チャンネル別、ユーザー別、全体統計を自動生成
- 🔍 **詳細なメッセージ情報**: 添付ファイル、リアクション、メンション、返信情報を含む
- 📅 **日付範囲指定**: 特定の期間のメッセージのみエクスポート可能
- 🎛️ **メッセージ数制限**: チャンネル毎にメッセージ数制限を設定可能

## 必要な環境

- Python 3.7+
- Discord Bot Token

## インストール

1. 必要なライブラリをインストール：
```bash
pip install -r requirements.txt
```

2. Discord Bot Tokenを取得：
   - [Discord Developer Portal](https://discord.com/developers/applications)でBotを作成
   - Bot TokenをコピーしてBotに必要な権限を付与
   - サーバーにBotを招待

## 使用方法

### 1. 基本的な使用手順

#### ステップ1: チャンネル情報の取得
最初にDiscordサーバーの全チャンネル情報を取得し、JSONファイルに保存します：

```bash
python discord_exporter.py -t "YOUR_BOT_TOKEN" --fetch-channels -o dummy.xlsx
```

#### ステップ2: インタラクティブエクスポート
保存されたチャンネル情報から選択してエクスポートします：

```bash
python discord_exporter.py -t "YOUR_BOT_TOKEN" --interactive -o "chat_export.xlsx"
```

### 2. コマンドオプション

| オプション | 説明 | 必須 |
|-----------|------|------|
| `-t, --token` | Discord Bot Token | ✅ |
| `--fetch-channels` | 全チャンネル情報を取得してJSONに保存 | - |
| `--interactive` | インタラクティブなチャンネル選択モード | - |
| `-c, --channel` | 単一チャンネルID（従来モード） | - |
| `-o, --output` | 出力Excelファイル名 | ✅ |
| `--after` | この日付以降のメッセージ（YYYY-MM-DD） | - |
| `--before` | この日付以前のメッセージ（YYYY-MM-DD） | - |
| `--limit` | チャンネル毎のメッセージ数制限 | - |

### 3. 使用例

#### 基本的な使用（推奨）
```bash
# 1. チャンネル情報を取得
python discord_exporter.py -t "YOUR_BOT_TOKEN" --fetch-channels -o dummy.xlsx

# 2. インタラクティブにエクスポート
python discord_exporter.py -t "YOUR_BOT_TOKEN" --interactive -o "discord_export.xlsx"
```

#### 日付範囲を指定してエクスポート
```bash
python discord_exporter.py -t "YOUR_BOT_TOKEN" --interactive -o "january_messages.xlsx" --after 2024-01-01 --before 2024-01-31
```

#### メッセージ数制限付きエクスポート
```bash
python discord_exporter.py -t "YOUR_BOT_TOKEN" --interactive -o "recent_messages.xlsx" --limit 1000
```

#### 単一チャンネルエクスポート（従来モード）
```bash
python discord_exporter.py -t "YOUR_BOT_TOKEN" -c 123456789012345678 -o "single_channel.xlsx"
```

## インタラクティブモードの使い方

### チャンネル選択画面
```
📋 利用可能なチャンネル:
================================================================================
 1. [マイサーバー] #general (推定: 1,234 メッセージ)
 2. [マイサーバー] #random (推定: 567 メッセージ)
 3. [マイサーバー] #dev (推定: 890 メッセージ)
================================================================================
総推定メッセージ数: 2,691

🎯 エクスポートしたいチャンネルを選択してください:
   - 番号をカンマ区切りで入力 (例: 1,3,5-7)
   - 範囲指定可能 (例: 1-5)
   - 'all' で全選択

選択: 1,3
```

### 選択方法
- **単一選択**: `1`
- **複数選択**: `1,3,5`
- **範囲選択**: `1-5`
- **組み合わせ**: `1,3,5-7,10`
- **全選択**: `all`

## 出力ファイル形式

生成されるExcelファイルには以下のシートが含まれます：

### 1. All_Messages
全メッセージの詳細情報
- タイムスタンプ
- 投稿者名・ID
- メッセージ内容
- サーバー名・チャンネル名
- 編集日時
- 返信先メッセージ
- 添付ファイル情報
- リアクション情報
- メンション情報
- Bot判定
- メッセージタイプ

### 2. Channel_Statistics
チャンネル別統計
- メッセージ数
- ユニークユーザー数
- 添付ファイル数
- リアクション数

### 3. User_Statistics
ユーザー別統計（チャンネル毎）
- メッセージ数
- 添付ファイル数
- リアクション数

### 4. Total_Statistics
全体統計
- 総メッセージ数
- 総チャンネル数
- 総ユーザー数
- 総添付ファイル数
- リアクション付きメッセージ数
- エクスポート日時

## 注意事項

### 大量データの処理
- 50,000メッセージを超える場合は警告が表示されます
- 処理時間とメモリ使用量が大きくなる可能性があります
- 日付範囲指定やメッセージ数制限の使用を推奨します

### Bot権限
Botには以下の権限が必要です：
- `Read Messages`
- `Read Message History`
- `View Channels`

### レート制限
- Discord APIのレート制限により、大量のメッセージ取得時は時間がかかる場合があります
- 100メッセージ毎に進捗が表示されます

## ファイル構造

```
discord_exporter/
├── discord_exporter.py    # メインスクリプト
├── requirements.txt       # 依存関係
├── README.md             # このファイル
└── channels.json         # チャンネル情報（自動生成）
```

## トラブルシューティング

### よくある問題

1. **Bot Tokenが無効**
   - Discord Developer Portalでトークンを確認
   - トークンが正しく入力されているか確認

2. **チャンネルが見つからない**
   - Botがそのチャンネルにアクセス権を持っているか確認
   - チャンネルIDが正しいか確認

3. **権限エラー**
   - Botに必要な権限が付与されているか確認
   - サーバーでBotが適切な役割を持っているか確認

4. **メモリ不足**
   - 大量のメッセージを扱う場合は、日付範囲やメッセージ数制限を使用
   - より多くのRAMを持つ環境での実行を検討

### ログ出力例

```
🔍 チャンネル情報を取得中...
サーバー: マイサーバー
  #general (推定メッセージ数: 1234)
  #random (推定メッセージ数: 567)
✅ チャンネル情報を channels.json に保存しました

🔄 [マイサーバー] #general を処理中...
  取得済み: 100 メッセージ
  取得済み: 200 メッセージ
✅ general: 234 メッセージ取得完了

✅ エクスポート完了!
   ファイル: discord_export.xlsx
   総メッセージ数: 1,234
   チャンネル数: 2
   ユーザー数: 45
```

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 貢献

バグ報告や機能要求は、GitHubのIssueでお知らせください。