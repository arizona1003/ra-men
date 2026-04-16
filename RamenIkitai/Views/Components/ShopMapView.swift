import SwiftUI
import MapKit

/// 店舗詳細用のミニマップ。単一店舗の位置を表示し、
/// タップで大きな地図表示または Apple Maps を開く。
struct ShopMiniMapView: View {
    let shop: Shop
    var height: CGFloat = 180

    @State private var position: MapCameraPosition

    init(shop: Shop, height: CGFloat = 180) {
        self.shop = shop
        self.height = height
        self._position = State(initialValue: .region(
            MKCoordinateRegion(
                center: shop.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        ))
    }

    var body: some View {
        Map(position: $position, interactionModes: []) {
            Marker(shop.name, systemImage: "fork.knife", coordinate: shop.coordinate)
                .tint(Theme.primary)
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(Theme.border, lineWidth: 1)
        )
    }
}

/// 複数店舗を地図上に表示する。検索結果のマップビューで利用。
struct ShopsMapView: View {
    let shops: [Shop]
    let userLocation: CLLocation?
    var onSelect: (Shop) -> Void

    @State private var position: MapCameraPosition = .automatic
    @State private var selectedShopID: UUID?

    var body: some View {
        Map(position: $position, selection: $selectedShopID) {
            ForEach(shops) { shop in
                Marker(shop.name, systemImage: "fork.knife", coordinate: shop.coordinate)
                    .tint(shop.genre.color)
                    .tag(shop.id)
            }
            if userLocation != nil {
                UserAnnotation()
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
        }
        .onAppear { frame() }
        .onChange(of: shops) { _, _ in frame() }
        .onChange(of: selectedShopID) { _, newValue in
            if let id = newValue, let shop = shops.first(where: { $0.id == id }) {
                onSelect(shop)
                selectedShopID = nil
            }
        }
    }

    private func frame() {
        guard !shops.isEmpty else {
            position = .automatic
            return
        }
        if shops.count == 1, let one = shops.first {
            position = .region(MKCoordinateRegion(
                center: one.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))
            return
        }
        let lats = shops.map(\.latitude)
        let lons = shops.map(\.longitude)
        guard let minLat = lats.min(), let maxLat = lats.max(),
              let minLon = lons.min(), let maxLon = lons.max() else { return }
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.02, (maxLat - minLat) * 1.4),
            longitudeDelta: max(0.02, (maxLon - minLon) * 1.4)
        )
        position = .region(MKCoordinateRegion(center: center, span: span))
    }
}

/// 店舗の位置情報を Apple Maps で開くためのヘルパー
enum MapsLauncher {
    @MainActor
    static func openInAppleMaps(_ shop: Shop) {
        let placemark = MKPlacemark(coordinate: shop.coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = shop.name
        item.openInMaps(launchOptions: [
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue
        ])
    }
}
