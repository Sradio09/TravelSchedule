import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

struct SettingsView: View {
    var body: some View {
        List {
            Section("Отладка") {
                Button("Проверить API (smoke test)") {
                    runNetworkSmokeTests()
                }
            }
            
            Section("О приложении") {
                Text("TravelSchedule")
                    .font(.headline)
            }
        }
        .background(Color("YPWhite"))
        .navigationTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private func runNetworkSmokeTests() {
    Task {
        do {
            let key = APIKey.yandexRasp
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport(),
                middlewares: [
                    APIKeyQueryMiddleware(apiKey: APIKey.yandexRasp)
                ]
            )
            
            let nearestStations = NearestStationsService(client: client, apikey: key)
            let searchService = SearchBetweenStationsService(client: client, apikey: key)
            let scheduleService = ScheduleOnStationService(client: client, apikey: key)
            let threadService = ThreadStationsService(client: client, apikey: key)
            let nearestSettlementService = NearestSettlementService(client: client, apikey: key)
            let carrierService = CarrierInfoService(client: client, apikey: key)
            let stationsListService = StationsListService(client: client, apikey: key)
            let copyrightService = CopyrightService(client: client, apikey: key)
            
            do {
                let result = try await nearestStations.getNearestStations(
                    lat: 59.864177,
                    lng: 30.319163,
                    distance: 50
                )
                print("✅ nearest_stations OK: \(result)")
            } catch {
                print("❌ nearest_stations error: \(error)")
            }
            
            var threadUID: String? = nil
            do {
                let data = try await searchService.searchRawData(
                    from: "c146",
                    to: "c213",
                    date: nil
                )
                threadUID = ThreadUIDExtractor.firstThreadUID(from: data)
                print("✅ search OK. threadUID: \(threadUID ?? "nil")")
            } catch {
                print("❌ search error: \(error)")
            }
            
            do {
                let result = try await scheduleService.getSchedule(
                    station: "s9600213",
                    date: nil
                )
                print("✅ schedule OK: \(result)")
            } catch {
                print("❌ schedule error: \(error)")
            }
            
            do {
                if let uid = threadUID {
                    let result = try await threadService.getThread(uid: uid, date: nil)
                    print("✅ thread OK: \(result)")
                } else {
                    print("⏭️ thread skipped: uid not found in search response")
                }
            } catch {
                print("❌ thread error: \(error)")
            }
            
            do {
                let result = try await nearestSettlementService.getNearestSettlement(
                    lat: 59.864177,
                    lng: 30.319163
                )
                print("✅ nearest_settlement OK: \(result)")
            } catch {
                print("❌ nearest_settlement error: \(error)")
            }
            
            do {
                let result = try await carrierService.getCarrier(code: 680)
                print("✅ carrier OK: \(result)")
            } catch {
                print("❌ carrier error: \(error)")
            }
            
            do {
                let data = try await stationsListService.loadStationsData()
                let preview = String(data: data, encoding: .utf8)?.prefix(200) ?? "no preview"
                print("✅ stations_list OK (preview 200 chars): \(preview)")
            } catch {
                print("❌ stations_list error: \(error)")
            }
            
            do {
                let result = try await copyrightService.getCopyright()
                print("✅ copyright OK: \(result)")
            } catch {
                print("❌ copyright error: \(error)")
            }
            
        } catch {
            print("❌ Failed to init Client: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
