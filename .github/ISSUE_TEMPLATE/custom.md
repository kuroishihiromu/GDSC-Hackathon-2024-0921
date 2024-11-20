---
name: Custom issue template
about: Describe this issue template's purpose here.
title: ''
labels: ''
assignees: ''

---

## 目的
`stamps, events`の管理を現状supabaseのみで管理しているため、イベントの主催側が確認できるようなページの作成

## 親Issue

## Issue分類
- [x] 設計
- [ ] 機能追加
- [ ] バグ修正

## チケットのゴール
管理者ページで`stamps, events`のCRUD処理を実装する

## 詳細
- Reactでちゃちゃっと作りたい(Flutterで実装しようと思うと骨が折れる、Webで閲覧できれば問題ない)
- 単一イベント単一adminユーザーでの実装(ユーザー情報にイベントidを含める、など)

## 作業
- [ ] 何らかのイベント情報と紐づく形でユーザー情報の設計
- [ ] イベント情報のCRUDをトップページで実装
- [ ] 該当するイベントに属する`stamps`のReadをスタンプ一覧として確認、新規スタンプ情報のCreateの実装
- [ ] スタンプ情報のUpdate, Deleteを詳細画面として実装
