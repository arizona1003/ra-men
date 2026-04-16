# ラーメンイキタイ 🍜

> ラーメン食べたい

サウナイキタイにインスパイアされた、ラーメン特化型の iOS アプリです。全国のラーメン店を検索・記録できる、ラーメン好きのためのアプリ。SwiftUI で実装されています。

## 特徴

- **ホーム** — 注目のラーメン店、ジャンル検索、最新のラー活
- **検索** — キーワード / ジャンル / エリア / 評価順・近い順で絞り込み、**リスト / 地図の切替表示**
- **店舗詳細** — 基本情報・スペック（麺・スープ）・メニュー・ラー活一覧、**地図表示 & Apple マップ経路**
- **ラー活を記録** — 訪問日、注文メニュー、総合評価、スープ / 麺 / 具 の詳細評価、感想、**写真最大 4 枚**
- **行きたいリスト** — 気になるお店をブックマーク
- **ランキング** — 総合・ジャンル別のランキング
- **マイページ** — ラー活履歴、行きたいリスト、プロフィール編集
- **現在地連携（MapKit / CoreLocation）** — 現在地からの距離表示、近い順ソート、検索結果の地図ピン表示

## サウナイキタイ → ラーメンイキタイ 対応表

| サウナイキタイ          | ラーメンイキタイ             |
| ----------------------- | ---------------------------- |
| サ活（サウナ活動）      | ラー活（ラーメン活動）       |
| 行きたい                | 行きたい                     |
| サウナ室温度 / 水風呂温度 | スープ（こってり〜あっさり） |
| 外気浴 / ととのう       | 替え玉 / 麺の太さ            |
| サウナランキング        | ラーメンランキング           |

## 動作環境

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## プロジェクト構造

```
RamenIkitai/
├── RamenIkitaiApp.swift           # @main アプリエントリ
├── ContentView.swift               # TabView（ホーム/検索/ランキング/マイページ）
├── Info.plist
├── Models/
│   ├── Genre.swift                 # ラーメンジャンル（醤油・味噌・塩・豚骨…）
│   ├── Shop.swift                  # ラーメン店モデル
│   └── Review.swift                # ラー活（レビュー）モデル
├── Store/
│   ├── AppStore.swift              # ObservableObject + UserDefaults 永続化
│   ├── LocationManager.swift       # CoreLocation ラッパー
│   ├── PhotoStore.swift            # 画像の Documents 保存ヘルパー
│   └── SampleData.swift            # サンプル店舗データ（12店、緯度経度つき）
├── Theme/
│   └── Theme.swift                 # カラーパレット
├── Views/
│   ├── HomeView.swift
│   ├── SearchView.swift
│   ├── ShopDetailView.swift
│   ├── ReviewFormView.swift        # ラー活投稿フォーム
│   ├── RankingView.swift
│   ├── MyPageView.swift
│   └── Components/
│       ├── RatingView.swift        # 星評価表示 / 入力
│       ├── ShopCard.swift
│       ├── ShopRow.swift
│       ├── ShopMapView.swift       # MapKit ベースの地図ビュー
│       └── PhotoViews.swift        # サムネ / 全画面ビューア（ピンチズーム）
└── Assets.xcassets/
```

## セットアップ

### 方法 1: XcodeGen でプロジェクトを生成（推奨）

[XcodeGen](https://github.com/yonaskolb/XcodeGen) がインストールされていない場合:

```bash
brew install xcodegen
```

プロジェクトのルートで以下を実行:

```bash
xcodegen generate
open RamenIkitai.xcodeproj
```

Xcode が起動したら、シミュレータまたは実機を選んで ⌘R で実行してください。

### 方法 2: Xcode から新規プロジェクトを作成

1. Xcode で「File > New > Project」から **iOS App** を選択
2. Product Name: `RamenIkitai`、Interface: **SwiftUI**、Language: **Swift** で作成
3. 生成されたプロジェクトの既定の `ContentView.swift` / `…App.swift` / `Assets.xcassets` を削除
4. このリポジトリの `RamenIkitai/` フォルダ配下のファイル（`Models/`, `Store/`, `Theme/`, `Views/`, `RamenIkitaiApp.swift`, `ContentView.swift`, `Assets.xcassets`, `Info.plist`）を Xcode のプロジェクトにドラッグ＆ドロップ（「Copy items if needed」「Create groups」を選択）
5. ターゲットの **Deployment Target** を `17.0` に設定
6. ⌘R でビルド・実行

## MapKit / 位置情報

- `ShopDetailView` に店舗位置のミニマップと「Apple マップで経路を確認」ボタンを実装
- `SearchView` でリスト / 地図の切替が可能。地図ではジャンル色のピンが立ち、タップで詳細へ遷移
- 検索の並び替えに「近い順」を追加。選択時に位置情報の利用許可をリクエスト
- 位置情報許可時は、検索結果・地図に現在地が表示される
- 権限: `Info.plist` に `NSLocationWhenInUseUsageDescription` を設定済み
- iOS 17+ の新しい SwiftUI Map API（`Map(position:)` + `Marker`）を使用、`MKMapItem.openInMaps(launchOptions:)` で経路案内へ遷移

## 写真アップロード

- ラー活の投稿時に `PhotosPicker` から最大 4 枚まで写真を添付可能
- 画像は自動で最大 1600px にリサイズ、JPEG 品質 0.85 で `Documents/review_photos/` に保存
- ファイル名のみ `Review.photoFilenames` に保存し、`UserDefaults` への肥大化を防止
- レビュー削除時・「すべてのデータをリセット」時にディスク上の画像もクリーンアップ
- 最新のラー活写真を **店舗詳細のヒーロー画像** と **店舗カードのサムネ** として自動表示
- サムネをタップすると全画面ビューア（ピンチズーム、ダブルタップ、ページング）が開く
- `PhotosPicker(photoLibrary: .shared())` を使用するため `NSPhotoLibraryUsageDescription` は不要

## 永続化について

- ラー活・行きたい・ユーザープロフィールは `UserDefaults` に JSON シリアライズで保存されます
- 画像バイナリは Documents ディレクトリにファイルとして保存されます
- マイページの「すべてのデータをリセット」で初期状態に戻せます

## サンプルデータについて

`Store/SampleData.swift` に 12 店舗のサンプルデータ（東京・横浜・札幌・福岡など）が収録されています。店舗名・住所は架空のものです。

## デザイン

- メインカラー: 醤油色ベースの暖色（#D14836）
- アクセントカラー: 卵黄のような黄色（#F6B93B）
- ジャンルごとに固有色を設定（醤油=茶、味噌=味噌色、塩=薄青、豚骨=ベージュ…）
- UI は SwiftUI の標準コンポーネントで構成、外部ライブラリ不使用

## ライセンス

個人利用・学習目的のサンプルプロジェクトです。
