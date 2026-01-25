import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("TravelSchedule")
        }
        .padding()
        .onAppear {
            runNetworkSmokeTests()
        }
    }
}

private func runNetworkSmokeTests() {
    Task {
        do {
            let client = Client(
                serverURL: try Servers.Server1.url(),
                transport: URLSessionTransport()
            )

            let key = APIKey.yandexRasp

            let nearestStations = NearestStationsService(client: client, apikey: key)
            let searchService = SearchBetweenStationsService(client: client, apikey: key)
            let scheduleService = ScheduleOnStationService(client: client, apikey: key)
            let threadService = ThreadStationsService(client: client, apikey: key)
            let nearestSettlementService = NearestSettlementService(client: client, apikey: key)
            let carrierService = CarrierInfoService(client: client, apikey: key)
            let stationsListService = StationsListService(client: client, apikey: key)
            let copyrightService = CopyrightService(client: client, apikey: key)

            // ✅ Список ближайших станций
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

            // ✅ Расписание рейсов между станциями
            do {
                let result = try await searchService.search(
                    from: "c146",
                    to: "c213",
                    date: nil
                )
                print("✅ search OK: \(result)")
            } catch {
                print("❌ search error: \(error)")
            }

            // ✅ Расписание рейсов по станции
            do {
                let result = try await scheduleService.getSchedule(
                    station: "s9600213",
                    date: nil
                )
                print("✅ schedule OK: \(result)")
            } catch {
                print("❌ schedule error: \(error)")
            }

            // ✅ Список станций следования
            do {
                let result = try await threadService.getThread(
                    uid: "UID_HERE",
                    date: nil
                )
                print("✅ thread OK: \(result)")
            } catch {
                print("❌ thread error: \(error)")
            }

            // ✅ Ближайший город
            do {
                let result = try await nearestSettlementService.getNearestSettlement(
                    lat: 59.864177,
                    lng: 30.319163
                )
                print("✅ nearest_settlement OK: \(result)")
            } catch {
                print("❌ nearest_settlement error: \(error)")
            }

            // ✅ Информация о перевозчике
            do {
                let result = try await carrierService.getCarrier(code: 680)
                print("✅ carrier OK: \(result)")
            } catch {
                print("❌ carrier error: \(error)")
            }

            // ✅ Список всех доступных станций
            do {
                let result = try await stationsListService.getAllStations()
                let preview = String(describing: result).prefix(200)
                print("✅ stations_list OK (preview 200 chars): \(preview)")
            } catch {
                print("❌ stations_list error: \(error)")
            }

            // ✅ Копирайт
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
    ContentView()
}
