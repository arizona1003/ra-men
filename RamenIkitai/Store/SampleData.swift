import Foundation

enum SampleData {
    static func makeShops() -> [Shop] {
        [
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000001")!,
                name: "麺屋 龍神",
                nameKana: "めんや りゅうじん",
                genre: .shoyu,
                prefecture: "東京都",
                area: "新宿区",
                address: "東京都新宿区西新宿1-2-3",
                nearestStation: "新宿駅 西口 徒歩3分",
                openHours: "11:00 - 22:00",
                closedDay: "日曜日",
                priceRange: "¥900 - ¥1,500",
                hasParking: false,
                acceptsReservation: false,
                offersKaedama: true,
                description: "鶏ガラと魚介のWスープが自慢の醤油ラーメン専門店。自家製麺のコシと香り高いスープの相性が絶品。",
                menus: [
                    .init(name: "特製醤油ラーメン", price: 1200, isSignature: true),
                    .init(name: "醤油ラーメン", price: 900),
                    .init(name: "味玉醤油", price: 1050),
                    .init(name: "チャーシュー麺", price: 1400),
                    .init(name: "替え玉", price: 150)
                ],
                noodleThickness: .medium,
                soupRichness: .medium,
                latitude: 35.6906,
                longitude: 139.6995
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000002")!,
                name: "味噌蔵 北の恵み",
                nameKana: "みそぐら きたのめぐみ",
                genre: .miso,
                prefecture: "北海道",
                area: "札幌市中央区",
                address: "北海道札幌市中央区南1条西5-8",
                nearestStation: "大通駅 徒歩5分",
                openHours: "11:30 - 21:00",
                closedDay: "水曜日",
                priceRange: "¥1,000 - ¥1,800",
                hasParking: true,
                acceptsReservation: false,
                offersKaedama: false,
                description: "北海道産味噌と炒め野菜が織りなす、濃厚で奥深い一杯。寒い日に食べたくなる札幌味噌の王道。",
                menus: [
                    .init(name: "味噌ラーメン", price: 1100, isSignature: true),
                    .init(name: "辛味噌ラーメン", price: 1250),
                    .init(name: "味噌バターコーン", price: 1350),
                    .init(name: "特製味噌", price: 1650)
                ],
                noodleThickness: .thick,
                soupRichness: .rich,
                latitude: 43.0614,
                longitude: 141.3544
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000003")!,
                name: "塩ラーメン 海の音",
                nameKana: "しおらーめん うみのおと",
                genre: .shio,
                prefecture: "神奈川県",
                area: "横浜市中区",
                address: "神奈川県横浜市中区山下町12-3",
                nearestStation: "元町・中華街駅 徒歩2分",
                openHours: "11:00 - 15:00 / 17:00 - 21:00",
                closedDay: "火曜日",
                priceRange: "¥850 - ¥1,300",
                hasParking: false,
                acceptsReservation: false,
                offersKaedama: false,
                description: "透き通る黄金スープに、三陸産の昆布と真鯛の出汁が香る塩ラーメン。繊細さが光る一杯。",
                menus: [
                    .init(name: "塩ラーメン", price: 950, isSignature: true),
                    .init(name: "特製塩", price: 1300),
                    .init(name: "塩つけ麺", price: 1100),
                    .init(name: "和え玉", price: 300)
                ],
                noodleThickness: .thin,
                soupRichness: .light,
                latitude: 35.4428,
                longitude: 139.6487
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000004")!,
                name: "博多豚骨 白龍",
                nameKana: "はかたとんこつ はくりゅう",
                genre: .tonkotsu,
                prefecture: "福岡県",
                area: "福岡市博多区",
                address: "福岡県福岡市博多区中洲3-7-1",
                nearestStation: "中洲川端駅 徒歩4分",
                openHours: "18:00 - 翌3:00",
                closedDay: "無休",
                priceRange: "¥750 - ¥1,200",
                hasParking: false,
                acceptsReservation: false,
                offersKaedama: true,
                description: "深夜まで営業する博多の名店。18時間炊き込んだ濃厚豚骨と極細ストレート麺の黄金比。",
                menus: [
                    .init(name: "豚骨ラーメン", price: 800, isSignature: true),
                    .init(name: "ネギ豚骨", price: 950),
                    .init(name: "チャーシュー麺", price: 1200),
                    .init(name: "替え玉", price: 120)
                ],
                noodleThickness: .thin,
                soupRichness: .rich,
                latitude: 33.5945,
                longitude: 130.4099
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000005")!,
                name: "家系総本山 剛家",
                nameKana: "いえけいそうほんざん ごうや",
                genre: .iekei,
                prefecture: "神奈川県",
                area: "横浜市鶴見区",
                address: "神奈川県横浜市鶴見区鶴見中央4-5-6",
                nearestStation: "鶴見駅 徒歩3分",
                openHours: "10:30 - 23:00",
                closedDay: "無休",
                priceRange: "¥850 - ¥1,400",
                hasParking: true,
                acceptsReservation: false,
                offersKaedama: true,
                description: "豚骨醤油のキレと酒井製麺の中太麺、ほうれん草・海苔・チャーシュー。家系の王道を受け継ぐ一杯。",
                menus: [
                    .init(name: "ラーメン（並）", price: 850, isSignature: true),
                    .init(name: "ラーメン（中）", price: 950),
                    .init(name: "ネギラーメン", price: 1100),
                    .init(name: "チャーシュー麺", price: 1400),
                    .init(name: "ライス", price: 100)
                ],
                noodleThickness: .medium,
                soupRichness: .rich,
                latitude: 35.5087,
                longitude: 139.6762
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000006")!,
                name: "ラーメン 豚将軍",
                nameKana: "らーめん ぶたしょうぐん",
                genre: .jiro,
                prefecture: "東京都",
                area: "千代田区",
                address: "東京都千代田区神田小川町2-8",
                nearestStation: "小川町駅 徒歩1分",
                openHours: "11:00 - 14:30 / 17:30 - 22:00",
                closedDay: "日曜日",
                priceRange: "¥800 - ¥1,100",
                hasParking: false,
                acceptsReservation: false,
                offersKaedama: false,
                description: "野菜・ニンニク・背脂の三重奏。ガッツリ系の代表格。コールは「全マシ」で挑もう。",
                menus: [
                    .init(name: "ラーメン", price: 800, isSignature: true),
                    .init(name: "豚入りラーメン", price: 1000),
                    .init(name: "ラーメン小", price: 750),
                    .init(name: "汁なし", price: 900)
                ],
                noodleThickness: .extraThick,
                soupRichness: .extraRich,
                latitude: 35.6958,
                longitude: 139.7656
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000007")!,
                name: "つけ麺 大河",
                nameKana: "つけめん たいが",
                genre: .tsukemen,
                prefecture: "埼玉県",
                area: "さいたま市大宮区",
                address: "埼玉県さいたま市大宮区桜木町2-3-4",
                nearestStation: "大宮駅 徒歩6分",
                openHours: "11:00 - 15:00 / 18:00 - 22:00",
                closedDay: "月曜日",
                priceRange: "¥950 - ¥1,500",
                hasParking: false,
                acceptsReservation: false,
                offersKaedama: false,
                description: "濃厚魚介豚骨つけ汁に、もちもちの極太麺が絡む。スープ割りまで楽しんでほしい。",
                menus: [
                    .init(name: "つけ麺（並）", price: 950, isSignature: true),
                    .init(name: "つけ麺（大）", price: 1050),
                    .init(name: "特製つけ麺", price: 1500),
                    .init(name: "あつもり", price: 0)
                ],
                noodleThickness: .extraThick,
                soupRichness: .rich,
                latitude: 35.9062,
                longitude: 139.6235
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000008")!,
                name: "担々麺 花椒楼",
                nameKana: "たんたんめん かしょうろう",
                genre: .tantanmen,
                prefecture: "東京都",
                area: "港区",
                address: "東京都港区麻布十番2-1-5",
                nearestStation: "麻布十番駅 徒歩3分",
                openHours: "11:30 - 15:00 / 17:30 - 22:30",
                closedDay: "無休",
                priceRange: "¥1,100 - ¥1,700",
                hasParking: false,
                acceptsReservation: true,
                offersKaedama: false,
                description: "四川花椒の痺れと芝麻醤のコク。痺れと旨みの絶妙なバランスで中毒になる一杯。",
                menus: [
                    .init(name: "汁あり担々麺", price: 1200, isSignature: true),
                    .init(name: "汁なし担々麺", price: 1250),
                    .init(name: "特製担々麺", price: 1600)
                ],
                noodleThickness: .thin,
                soupRichness: .rich,
                latitude: 35.6569,
                longitude: 139.7363
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000009")!,
                name: "煮干し中華 青煮堂",
                nameKana: "にぼしちゅうか せいしどう",
                genre: .niboshi,
                prefecture: "東京都",
                area: "杉並区",
                address: "東京都杉並区高円寺南4-2-11",
                nearestStation: "高円寺駅 徒歩4分",
                openHours: "11:30 - 15:00",
                closedDay: "水曜・木曜",
                priceRange: "¥950 - ¥1,300",
                hasParking: false,
                acceptsReservation: false,
                offersKaedama: false,
                description: "青森産の片口イワシを贅沢に使用。煮干しの苦味と旨みが共存する、マニア向けの一杯。",
                menus: [
                    .init(name: "煮干し中華そば", price: 950, isSignature: true),
                    .init(name: "濃厚煮干し", price: 1050),
                    .init(name: "特製煮干し", price: 1300)
                ],
                noodleThickness: .thin,
                soupRichness: .medium,
                latitude: 35.7053,
                longitude: 139.6495
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000010")!,
                name: "油そば専門 脂の道",
                nameKana: "あぶらそばせんもん あぶらのみち",
                genre: .abura,
                prefecture: "東京都",
                area: "武蔵野市",
                address: "東京都武蔵野市吉祥寺本町1-10-4",
                nearestStation: "吉祥寺駅 徒歩5分",
                openHours: "11:00 - 23:00",
                closedDay: "無休",
                priceRange: "¥700 - ¥1,000",
                hasParking: false,
                acceptsReservation: false,
                offersKaedama: true,
                description: "タレと香味油が絡む一杯。酢とラー油で味変を楽しむのが通。",
                menus: [
                    .init(name: "油そば", price: 780, isSignature: true),
                    .init(name: "辛油そば", price: 850),
                    .init(name: "全部乗せ", price: 1000),
                    .init(name: "ライス", price: 50)
                ],
                noodleThickness: .thick,
                soupRichness: .medium,
                latitude: 35.7033,
                longitude: 139.5797
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000011")!,
                name: "札幌味噌 雪あかり",
                nameKana: "さっぽろみそ ゆきあかり",
                genre: .miso,
                prefecture: "北海道",
                area: "札幌市北区",
                address: "北海道札幌市北区北24条西5-1-1",
                nearestStation: "北24条駅 徒歩2分",
                openHours: "11:00 - 翌1:00",
                closedDay: "第3火曜日",
                priceRange: "¥950 - ¥1,500",
                hasParking: true,
                acceptsReservation: false,
                offersKaedama: false,
                description: "炒め野菜の香ばしさと三年熟成味噌。冬の札幌で食べたい、懐かしい味。",
                menus: [
                    .init(name: "味噌ラーメン", price: 980, isSignature: true),
                    .init(name: "味噌野菜", price: 1180),
                    .init(name: "特製味噌", price: 1500)
                ],
                noodleThickness: .thick,
                soupRichness: .rich,
                latitude: 43.0885,
                longitude: 141.3397
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000012")!,
                name: "中華そば 江戸の粋",
                nameKana: "ちゅうかそば えどのいき",
                genre: .shoyu,
                prefecture: "東京都",
                area: "中央区",
                address: "東京都中央区日本橋人形町1-5-8",
                nearestStation: "人形町駅 徒歩2分",
                openHours: "11:00 - 15:00 / 17:00 - 20:30",
                closedDay: "日曜・祝日",
                priceRange: "¥800 - ¥1,200",
                hasParking: false,
                acceptsReservation: false,
                offersKaedama: false,
                description: "東京ラーメンの神髄。鶏ガラ清湯に醤油の香り、ナルトとチャーシュー。飽きのこない王道。",
                menus: [
                    .init(name: "中華そば", price: 850, isSignature: true),
                    .init(name: "ワンタン麺", price: 1050),
                    .init(name: "特製中華そば", price: 1200)
                ],
                noodleThickness: .thin,
                soupRichness: .light,
                latitude: 35.6851,
                longitude: 139.7832
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000013")!,
                name: "博多の夜風", nameKana: "はかたのよかぜ", genre: .tonkotsu,
                prefecture: "福岡県", area: "福岡市中央区",
                address: "福岡県福岡市中央区天神2-3-10",
                nearestStation: "天神駅 徒歩5分", openHours: "11:00 - 翌2:00", closedDay: "無休",
                priceRange: "¥700 - ¥1,300",
                hasParking: false, acceptsReservation: false, offersKaedama: true,
                description: "天神の繁華街で愛される老舗豚骨。マイルドでクリーミーなスープが特徴。",
                menus: [
                    .init(name: "豚骨ラーメン", price: 780, isSignature: true),
                    .init(name: "辛子高菜ラーメン", price: 900),
                    .init(name: "替え玉", price: 130),
                    .init(name: "焼き餃子", price: 480)
                ],
                noodleThickness: .thin, soupRichness: .rich,
                latitude: 33.5903, longitude: 130.3975
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000014")!,
                name: "中華そば 雅", nameKana: "ちゅうかそば みやび", genre: .shoyu,
                prefecture: "京都府", area: "京都市下京区",
                address: "京都府京都市下京区四条烏丸南入ル",
                nearestStation: "四条駅 徒歩3分", openHours: "11:30 - 15:00 / 18:00 - 22:00", closedDay: "火曜日",
                priceRange: "¥900 - ¥1,400",
                hasParking: false, acceptsReservation: false, offersKaedama: false,
                description: "京都の古都に溶け込む優しい中華そば。昆布と鰹の出汁、澄んだ醤油スープが上品。",
                menus: [
                    .init(name: "中華そば", price: 950, isSignature: true),
                    .init(name: "特製中華そば", price: 1350),
                    .init(name: "チャーシュー丼", price: 450)
                ],
                noodleThickness: .thin, soupRichness: .light,
                latitude: 35.0002, longitude: 135.7609
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000015")!,
                name: "大阪豚骨 浪花亭", nameKana: "おおさかとんこつ なにわてい", genre: .tonkotsu,
                prefecture: "大阪府", area: "大阪市中央区",
                address: "大阪府大阪市中央区難波3-4-15",
                nearestStation: "難波駅 徒歩4分", openHours: "11:00 - 23:00", closedDay: "無休",
                priceRange: "¥800 - ¥1,400",
                hasParking: false, acceptsReservation: false, offersKaedama: true,
                description: "関西屈指の豚骨ラーメン。濃厚でクリーミー、醤油ダレを合わせた関西流のアレンジ。",
                menus: [
                    .init(name: "豚骨醤油ラーメン", price: 880, isSignature: true),
                    .init(name: "こってり豚骨", price: 980),
                    .init(name: "チャーシュー麺", price: 1380),
                    .init(name: "替え玉", price: 150)
                ],
                noodleThickness: .medium, soupRichness: .rich,
                latitude: 34.6665, longitude: 135.5006
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000016")!,
                name: "名古屋味噌 三河屋", nameKana: "なごやみそ みかわや", genre: .miso,
                prefecture: "愛知県", area: "名古屋市中区",
                address: "愛知県名古屋市中区栄3-8-12",
                nearestStation: "栄駅 徒歩6分", openHours: "11:00 - 14:30 / 17:30 - 22:00", closedDay: "月曜日",
                priceRange: "¥950 - ¥1,500",
                hasParking: false, acceptsReservation: false, offersKaedama: false,
                description: "名古屋の八丁味噌を使った独自スタイル。コクと甘みのバランスが絶妙。",
                menus: [
                    .init(name: "八丁味噌ラーメン", price: 980, isSignature: true),
                    .init(name: "辛味噌", price: 1150),
                    .init(name: "味噌煮込み風", price: 1400)
                ],
                noodleThickness: .thick, soupRichness: .rich,
                latitude: 35.1706, longitude: 136.9089
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000017")!,
                name: "仙台塩らーめん 伊達", nameKana: "せんだいしおらーめん だて", genre: .shio,
                prefecture: "宮城県", area: "仙台市青葉区",
                address: "宮城県仙台市青葉区一番町3-5-2",
                nearestStation: "青葉通一番町駅 徒歩3分", openHours: "11:00 - 21:00", closedDay: "水曜日",
                priceRange: "¥850 - ¥1,300",
                hasParking: false, acceptsReservation: false, offersKaedama: false,
                description: "三陸の海の幸を活かした塩ラーメン。貝と昆布の旨みが広がる、東北の実力派。",
                menus: [
                    .init(name: "塩らーめん", price: 900, isSignature: true),
                    .init(name: "ホタテ塩", price: 1250),
                    .init(name: "特製塩", price: 1300)
                ],
                noodleThickness: .thin, soupRichness: .light,
                latitude: 38.2606, longitude: 140.8720
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000018")!,
                name: "広島つけ麺 鯉", nameKana: "ひろしまつけめん こい", genre: .tsukemen,
                prefecture: "広島県", area: "広島市中区",
                address: "広島県広島市中区本通り8-12",
                nearestStation: "本通駅 徒歩2分", openHours: "11:00 - 15:00 / 17:30 - 22:00", closedDay: "無休",
                priceRange: "¥900 - ¥1,400",
                hasParking: false, acceptsReservation: false, offersKaedama: false,
                description: "広島名物の辛口つけ麺。ピリ辛ごまダレにキャベツとネギ、もちもちの中太麺が絡む。",
                menus: [
                    .init(name: "広島つけ麺（並）", price: 950, isSignature: true),
                    .init(name: "つけ麺（大）", price: 1050),
                    .init(name: "激辛つけ麺", price: 1100)
                ],
                noodleThickness: .medium, soupRichness: .medium,
                latitude: 34.3938, longitude: 132.4583
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000019")!,
                name: "神戸担々麺 華月", nameKana: "こうべたんたんめん かげつ", genre: .tantanmen,
                prefecture: "兵庫県", area: "神戸市中央区",
                address: "兵庫県神戸市中央区三宮町1-7-4",
                nearestStation: "三宮駅 徒歩5分", openHours: "11:30 - 21:30", closedDay: "第2火曜日",
                priceRange: "¥1,050 - ¥1,600",
                hasParking: false, acceptsReservation: true, offersKaedama: false,
                description: "港町神戸で磨かれた本格担々麺。中華街の技と四川の辛さが融合した逸品。",
                menus: [
                    .init(name: "汁あり担々麺", price: 1150, isSignature: true),
                    .init(name: "汁なし担々麺", price: 1200),
                    .init(name: "麻婆担々", price: 1500)
                ],
                noodleThickness: .thin, soupRichness: .rich,
                latitude: 34.6938, longitude: 135.1958
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000020")!,
                name: "喜多方中華 蔵元", nameKana: "きたかたちゅうか くらもと", genre: .shoyu,
                prefecture: "福島県", area: "喜多方市",
                address: "福島県喜多方市一本木上7-1",
                nearestStation: "喜多方駅 徒歩10分", openHours: "7:00 - 14:00", closedDay: "木曜日",
                priceRange: "¥750 - ¥1,100",
                hasParking: true, acceptsReservation: false, offersKaedama: false,
                description: "朝ラーで有名な喜多方。多加水の平打ち麺と淡麗醤油スープ、食後感が軽い。",
                menus: [
                    .init(name: "中華そば", price: 780, isSignature: true),
                    .init(name: "ネギ中華", price: 880),
                    .init(name: "チャーシュー麺", price: 1080)
                ],
                noodleThickness: .medium, soupRichness: .light,
                latitude: 37.6528, longitude: 139.8750
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000021")!,
                name: "函館塩ラーメン 海雪", nameKana: "はこだてしおらーめん うみゆき", genre: .shio,
                prefecture: "北海道", area: "函館市",
                address: "北海道函館市松風町2-3",
                nearestStation: "函館駅 徒歩8分", openHours: "11:00 - 20:00", closedDay: "火曜日",
                priceRange: "¥900 - ¥1,400",
                hasParking: true, acceptsReservation: false, offersKaedama: false,
                description: "函館伝統の塩ラーメン。澄んだ鶏ガラスープと利尻昆布の旨み、シンプルで深い味わい。",
                menus: [
                    .init(name: "塩ラーメン", price: 950, isSignature: true),
                    .init(name: "いくら塩", price: 1400),
                    .init(name: "特製塩", price: 1300)
                ],
                noodleThickness: .thin, soupRichness: .light,
                latitude: 41.7739, longitude: 140.7260
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000022")!,
                name: "旭川醤油 純吉", nameKana: "あさひかわしょうゆ じゅんきち", genre: .shoyu,
                prefecture: "北海道", area: "旭川市",
                address: "北海道旭川市2条通8-748",
                nearestStation: "旭川駅 徒歩12分", openHours: "11:00 - 20:30", closedDay: "水曜日",
                priceRange: "¥850 - ¥1,350",
                hasParking: true, acceptsReservation: false, offersKaedama: false,
                description: "旭川ラーメンの老舗。ラードで熱々のWスープ、寒冷地で冷めないラーメンの元祖。",
                menus: [
                    .init(name: "醤油ラーメン", price: 880, isSignature: true),
                    .init(name: "味玉醤油", price: 1030),
                    .init(name: "チャーシュー麺", price: 1350)
                ],
                noodleThickness: .medium, soupRichness: .medium,
                latitude: 43.7709, longitude: 142.3651
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000023")!,
                name: "渋谷家系 王座", nameKana: "しぶやいえけい おうざ", genre: .iekei,
                prefecture: "東京都", area: "渋谷区",
                address: "東京都渋谷区道玄坂2-15-8",
                nearestStation: "渋谷駅 徒歩5分", openHours: "11:00 - 23:00", closedDay: "無休",
                priceRange: "¥900 - ¥1,500",
                hasParking: false, acceptsReservation: false, offersKaedama: true,
                description: "渋谷の喧騒で腹を満たす家系。濃い目・脂多め・硬めのコールで真価を発揮。",
                menus: [
                    .init(name: "ラーメン（並）", price: 900, isSignature: true),
                    .init(name: "ネギラーメン", price: 1150),
                    .init(name: "チャーシュー麺", price: 1500),
                    .init(name: "ライス", price: 100)
                ],
                noodleThickness: .medium, soupRichness: .rich,
                latitude: 35.6590, longitude: 139.6982
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000024")!,
                name: "池袋豚骨 大豊", nameKana: "いけぶくろとんこつ たいほう", genre: .tonkotsu,
                prefecture: "東京都", area: "豊島区",
                address: "東京都豊島区南池袋1-25-10",
                nearestStation: "池袋駅 徒歩3分", openHours: "11:00 - 翌1:00", closedDay: "無休",
                priceRange: "¥800 - ¥1,300",
                hasParking: false, acceptsReservation: false, offersKaedama: true,
                description: "池袋の夜に輝く豚骨。東京アレンジの少しあっさり目スープ、翌朝まで胃もたれしない。",
                menus: [
                    .init(name: "豚骨ラーメン", price: 850, isSignature: true),
                    .init(name: "ネギ豚骨", price: 980),
                    .init(name: "替え玉", price: 130)
                ],
                noodleThickness: .thin, soupRichness: .rich,
                latitude: 35.7293, longitude: 139.7113
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000025")!,
                name: "中野煮干し 藍魚", nameKana: "なかのにぼし あいうお", genre: .niboshi,
                prefecture: "東京都", area: "中野区",
                address: "東京都中野区中野5-56-12",
                nearestStation: "中野駅 徒歩4分", openHours: "11:30 - 15:00 / 18:00 - 21:00", closedDay: "日曜日",
                priceRange: "¥950 - ¥1,400",
                hasParking: false, acceptsReservation: false, offersKaedama: false,
                description: "中野発の濃厚煮干し。煮干しの苦味を最大限に引き出した、通好みの一杯。",
                menus: [
                    .init(name: "濃厚煮干しそば", price: 1000, isSignature: true),
                    .init(name: "特製煮干し", price: 1400),
                    .init(name: "和え玉", price: 250)
                ],
                noodleThickness: .medium, soupRichness: .rich,
                latitude: 35.7056, longitude: 139.6659
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000026")!,
                name: "浅草中華 雷門", nameKana: "あさくさちゅうか かみなりもん", genre: .shoyu,
                prefecture: "東京都", area: "台東区",
                address: "東京都台東区浅草1-18-2",
                nearestStation: "浅草駅 徒歩3分", openHours: "11:00 - 20:00", closedDay: "月曜日",
                priceRange: "¥750 - ¥1,200",
                hasParking: false, acceptsReservation: false, offersKaedama: false,
                description: "下町浅草の老舗中華そば。三代続く秘伝のタレ、観光客も地元民も愛する昔ながらの味。",
                menus: [
                    .init(name: "中華そば", price: 800, isSignature: true),
                    .init(name: "ワンタン麺", price: 1000),
                    .init(name: "チャーシュー麺", price: 1200)
                ],
                noodleThickness: .thin, soupRichness: .light,
                latitude: 35.7145, longitude: 139.7969
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000027")!,
                name: "秋葉原油そば オタクの一杯", nameKana: "あきはばらあぶらそば おたくのいっぱい", genre: .abura,
                prefecture: "東京都", area: "千代田区",
                address: "東京都千代田区外神田3-12-1",
                nearestStation: "秋葉原駅 徒歩4分", openHours: "10:30 - 23:30", closedDay: "無休",
                priceRange: "¥650 - ¥1,000",
                hasParking: false, acceptsReservation: false, offersKaedama: true,
                description: "秋葉原で深夜まで営業する油そば。オタク向けの\"強火力\"メニューが名物。",
                menus: [
                    .init(name: "油そば", price: 700, isSignature: true),
                    .init(name: "特盛油そば", price: 850),
                    .init(name: "激辛油そば", price: 950),
                    .init(name: "ライス", price: 50)
                ],
                noodleThickness: .thick, soupRichness: .medium,
                latitude: 35.7022, longitude: 139.7744
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000028")!,
                name: "新潟濃厚味噌 雁木", nameKana: "にいがたのうこうみそ がんぎ", genre: .miso,
                prefecture: "新潟県", area: "新潟市中央区",
                address: "新潟県新潟市中央区古町通5-800",
                nearestStation: "新潟駅 バス10分", openHours: "11:00 - 20:30", closedDay: "火曜日",
                priceRange: "¥950 - ¥1,500",
                hasParking: true, acceptsReservation: false, offersKaedama: false,
                description: "新潟の極太濃厚味噌。生姜たっぷりで体の芯から温まる、雪国仕様の一杯。",
                menus: [
                    .init(name: "濃厚味噌ラーメン", price: 980, isSignature: true),
                    .init(name: "生姜味噌", price: 1150),
                    .init(name: "特製濃厚", price: 1500)
                ],
                noodleThickness: .extraThick, soupRichness: .rich,
                latitude: 37.9161, longitude: 139.0364
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000029")!,
                name: "久留米豚骨 元祖", nameKana: "くるめとんこつ がんそ", genre: .tonkotsu,
                prefecture: "福岡県", area: "久留米市",
                address: "福岡県久留米市東町40-12",
                nearestStation: "西鉄久留米駅 徒歩3分", openHours: "11:00 - 21:00", closedDay: "第3木曜日",
                priceRange: "¥700 - ¥1,200",
                hasParking: true, acceptsReservation: false, offersKaedama: true,
                description: "豚骨ラーメン発祥の地・久留米。煙のような濃厚スープ、ここでしか味わえない原点。",
                menus: [
                    .init(name: "豚骨ラーメン", price: 750, isSignature: true),
                    .init(name: "玉子入り", price: 850),
                    .init(name: "替え玉", price: 100)
                ],
                noodleThickness: .thin, soupRichness: .rich,
                latitude: 33.3192, longitude: 130.5085
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000030")!,
                name: "二郎系 熊王", nameKana: "じろうけい くまおう", genre: .jiro,
                prefecture: "神奈川県", area: "川崎市川崎区",
                address: "神奈川県川崎市川崎区駅前本町6-7",
                nearestStation: "川崎駅 徒歩2分", openHours: "11:00 - 14:30 / 17:00 - 22:00", closedDay: "日曜日",
                priceRange: "¥850 - ¥1,200",
                hasParking: false, acceptsReservation: false, offersKaedama: false,
                description: "関東屈指の二郎系。野菜は山盛り、ニンニクとアブラは当然マシマシ推奨。",
                menus: [
                    .init(name: "ラーメン", price: 850, isSignature: true),
                    .init(name: "豚ダブル", price: 1100),
                    .init(name: "小ラーメン", price: 750)
                ],
                noodleThickness: .extraThick, soupRichness: .extraRich,
                latitude: 35.5311, longitude: 139.6969
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000031")!,
                name: "沖縄ソーキそば 島風", nameKana: "おきなわそーきそば しまかぜ", genre: .shoyu,
                prefecture: "沖縄県", area: "那覇市",
                address: "沖縄県那覇市牧志3-2-10",
                nearestStation: "牧志駅 徒歩6分", openHours: "10:30 - 20:00", closedDay: "水曜日",
                priceRange: "¥700 - ¥1,100",
                hasParking: true, acceptsReservation: false, offersKaedama: false,
                description: "沖縄の風を感じる軟骨ソーキそば。鰹と豚骨のあっさりスープ、そば粉不使用の独自麺。",
                menus: [
                    .init(name: "ソーキそば", price: 800, isSignature: true),
                    .init(name: "三枚肉そば", price: 750),
                    .init(name: "ジューシー", price: 300)
                ],
                noodleThickness: .medium, soupRichness: .light,
                latitude: 26.2140, longitude: 127.6890
            ),
            Shop(
                id: UUID(uuidString: "11111111-1111-1111-1111-000000000032")!,
                name: "京都つけ麺 金閣", nameKana: "きょうとつけめん きんかく", genre: .tsukemen,
                prefecture: "京都府", area: "京都市北区",
                address: "京都府京都市北区金閣寺町1-5",
                nearestStation: "バス金閣寺道 徒歩2分", openHours: "11:00 - 15:00 / 17:00 - 21:00", closedDay: "木曜日",
                priceRange: "¥1,000 - ¥1,600",
                hasParking: true, acceptsReservation: false, offersKaedama: false,
                description: "魚介と鶏白湯のWスープつけ麺。古都の落ち着いた雰囲気でいただく贅沢な一杯。",
                menus: [
                    .init(name: "つけ麺（並）", price: 1050, isSignature: true),
                    .init(name: "つけ麺（大）", price: 1150),
                    .init(name: "特製つけ麺", price: 1600),
                    .init(name: "スープ割り", price: 0)
                ],
                noodleThickness: .extraThick, soupRichness: .rich,
                latitude: 35.0394, longitude: 135.7292
            )
        ]
    }

    static func makeReviews(for shops: [Shop]) -> [Review] {
        guard shops.count >= 6 else { return [] }
        return [
            Review(
                shopID: shops[0].id,
                visitedAt: Date().addingTimeInterval(-86_400 * 3),
                menu: "特製醤油ラーメン",
                overallRating: 5,
                soupScore: 5, noodleScore: 4, toppingScore: 5,
                comment: "鶏と魚介のバランスが絶妙。スープを最後まで飲み干した。"
            ),
            Review(
                shopID: shops[3].id,
                visitedAt: Date().addingTimeInterval(-86_400 * 7),
                menu: "豚骨ラーメン + 替え玉",
                overallRating: 4,
                soupScore: 5, noodleScore: 4, toppingScore: 3,
                comment: "濃厚だけど後味すっきり。替え玉はバリカタで。"
            ),
            Review(
                shopID: shops[5].id,
                visitedAt: Date().addingTimeInterval(-86_400 * 14),
                menu: "ラーメン 全マシ",
                overallRating: 4,
                soupScore: 4, noodleScore: 5, toppingScore: 4,
                comment: "覚悟の全マシ。麺のワシワシ感が最高。"
            )
        ]
    }
}
