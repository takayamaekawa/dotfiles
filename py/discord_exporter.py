#!/usr/bin/env python3
"""
Discord Chat to XLSX Exporter
Discordチャンネルから直接XLSXファイルにエクスポートするスクリプト
"""

import argparse
import asyncio
from datetime import datetime, timezone

import discord
import pandas as pd

# 必要なライブラリのインストール
# pip install discord.py pandas openpyxl


class DiscordExporter:
    def __init__(self, token):
        intents = discord.Intents.default()
        intents.message_content = True
        self.client = discord.Client(intents=intents)
        self.token = token

    async def export_channel_to_xlsx(
        self, channel_id, output_file, after_date=None, before_date=None, limit=None
    ):
        """
        DiscordチャンネルをXLSXファイルにエクスポート

        Args:
            channel_id (int): チャンネルID
            output_file (str): 出力ファイル名
            after_date (datetime): この日付以降のメッセージ
            before_date (datetime): この日付以前のメッセージ
            limit (int): メッセージ数の上限
        """

        await self.client.wait_until_ready()

        try:
            channel = self.client.get_channel(channel_id)
            if not channel:
                print(f"チャンネルID {channel_id} が見つかりません")
                return

            channel_name = getattr(channel, 'name', f'Channel {channel.id}')
            print(f"チャンネル '{channel_name}' からメッセージを取得中...")

            messages_data = []
            message_count = 0

            # メッセージ履歴を取得
            if not hasattr(channel, 'history'):
                print(f"チャンネル '{channel_name}' はメッセージ履歴を持っていません")
                return

            # 型チェック対応: channelを適切な型にキャスト
            from typing import cast
            import discord
            
            # メッセージ履歴を持つチャンネルの型を定義
            messageable_channel = cast(discord.abc.Messageable, channel)
            
            async for message in messageable_channel.history(
                limit=limit, after=after_date, before=before_date, oldest_first=False
            ):
                # 添付ファイルのURL取得
                attachments = []
                for attachment in message.attachments:
                    attachments.append(
                        {
                            "filename": attachment.filename,
                            "url": attachment.url,
                            "size": attachment.size,
                        }
                    )

                # リアクション情報
                reactions = []
                for reaction in message.reactions:
                    reactions.append(
                        {"emoji": str(reaction.emoji), "count": reaction.count}
                    )

                # メンション情報
                mentions = [user.display_name for user in message.mentions]

                # メッセージデータを構築
                message_data = {
                    "timestamp": message.created_at.strftime("%Y-%m-%d %H:%M:%S"),
                    "author_name": message.author.display_name,
                    "author_id": str(message.author.id),
                    "content": message.content,
                    "message_id": str(message.id),
                    "channel_name": channel_name,
                    "edited_at": message.edited_at.strftime("%Y-%m-%d %H:%M:%S")
                    if message.edited_at
                    else "",
                    "reply_to": str(message.reference.message_id)
                    if message.reference
                    else "",
                    "attachments_count": len(attachments),
                    "attachments_urls": "; ".join([att["url"] for att in attachments]),
                    "reactions_count": len(reactions),
                    "reactions": "; ".join(
                        [f"{r['emoji']}({r['count']})" for r in reactions]
                    ),
                    "mentions": "; ".join(mentions),
                    "is_bot": message.author.bot,
                    "message_type": str(message.type),
                }

                messages_data.append(message_data)
                message_count += 1

                if message_count % 100 == 0:
                    print(f"取得済み: {message_count} メッセージ")

            # DataFrameに変換
            df = pd.DataFrame(messages_data)

            # 時系列順にソート（古い順）
            df = df.sort_values("timestamp")

            # XLSXファイルに保存
            with pd.ExcelWriter(output_file, engine="openpyxl") as writer:
                # メインシート
                df.to_excel(writer, sheet_name="Messages", index=False)

                # 統計シート
                stats_data = {
                    "メトリック": [
                        "総メッセージ数",
                        "ユニークユーザー数",
                        "ボットメッセージ数",
                        "添付ファイル数",
                        "リアクション付きメッセージ数",
                        "エクスポート日時",
                        "チャンネル名",
                    ],
                    "値": [
                        len(df),
                        df["author_name"].nunique(),
                        len(df[df["is_bot"] == True]),
                        df["attachments_count"].sum(),
                        len(df[df["reactions_count"] > 0]),
                        datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                        channel_name,
                    ],
                }

                stats_df = pd.DataFrame(stats_data)
                stats_df.to_excel(writer, sheet_name="Statistics", index=False)

                # ユーザー別統計
                user_stats = (
                    df.groupby("author_name")
                    .agg(
                        {
                            "message_id": "count",
                            "attachments_count": "sum",
                            "reactions_count": "sum",
                        }
                    )
                    .rename({
                        "message_id": "メッセージ数",
                        "attachments_count": "添付ファイル数",
                        "reactions_count": "リアクション数",
                    }, axis=1)
                    .reset_index()
                )

                user_stats.to_excel(writer, sheet_name="User_Statistics", index=False)

            print("✅ エクスポート完了!")
            print(f"   ファイル: {output_file}")
            print(f"   メッセージ数: {len(df)}")
            print(f"   ユーザー数: {df['author_name'].nunique()}")

        except Exception as e:
            print(f"❌ エラー: {e}")

        finally:
            await self.client.close()


async def main():
    parser = argparse.ArgumentParser(description="Discord Chat to XLSX Exporter")
    parser.add_argument("-t", "--token", required=True, help="Discord Bot Token")
    parser.add_argument("-c", "--channel", required=True, type=int, help="Channel ID")
    parser.add_argument("-o", "--output", required=True, help="Output XLSX file")
    parser.add_argument("--after", help="After date (YYYY-MM-DD)")
    parser.add_argument("--before", help="Before date (YYYY-MM-DD)")
    parser.add_argument("--limit", type=int, help="Message limit")

    args = parser.parse_args()

    # 日付の解析
    after_date = None
    before_date = None

    if args.after:
        after_date = datetime.strptime(args.after, "%Y-%m-%d").replace(
            tzinfo=timezone.utc
        )

    if args.before:
        before_date = datetime.strptime(args.before, "%Y-%m-%d").replace(
            tzinfo=timezone.utc
        )

    # エクスポーター実行
    exporter = DiscordExporter(args.token)

    @exporter.client.event
    async def on_ready():
        print(f"ログイン: {exporter.client.user}")
        await exporter.export_channel_to_xlsx(
            args.channel, args.output, after_date, before_date, args.limit
        )

    await exporter.client.start(args.token)


if __name__ == "__main__":
    asyncio.run(main())

# 使用例:
# python discord_exporter.py -t "YOUR_BOT_TOKEN" -c 123456789 -o "chat.xlsx"
# python discord_exporter.py -t "YOUR_BOT_TOKEN" -c 123456789 -o "chat.xlsx" --after 2024-01-01 --before 2024-12-31
# python discord_exporter.py -t "YOUR_BOT_TOKEN" -c 123456789 -o "chat.xlsx" --limit 1000
