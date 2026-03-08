import SwiftUI

struct CitySearchView: View {
    
    let title: String
    let onSelect: (StationChoice) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var cities: [StationChoice] = []
    @State private var isLoading = true
    @State private var loadError: LoadError?
    @State private var selectedCity: StationChoice?
    
    private let popularCitiesOrder: [String] = [
        "Москва",
        "Санкт-Петербург",
        "Казань",
        "Нижний Новгород",
        "Сочи",
        "Екатеринбург",
        "Краснодар",
        "Ростов-на-Дону",
        "Новосибирск",
        "Самара"
    ]
    
    enum LoadError {
        case noInternet
        case server
    }
    
    private var filteredCities: [StationChoice] {
        guard !searchText.isEmpty else { return cities }
        
        return cities.filter { city in
            city.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 12) {
                    Spacer()
                    ProgressView()
                    Text("Загружаем города…")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else if let loadError {
                switch loadError {
                case .noInternet:
                    NoInternetView()
                case .server:
                    ServerErrorView()
                }
            } else {
                List(filteredCities) { city in
                    Button {
                        selectedCity = city
                    } label: {
                        HStack {
                            Text(city.title)
                                .font(.system(size: 17))
                                .foregroundStyle(Color("YPBlack"))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color("YPBlack"))
                                .padding(.trailing, 16)
                        }
                        .frame(height: 60)
                        .padding(.leading, 16)
                        .background(Color("YPWhite"))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color("YPWhite"))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color("YPWhite"))
                .searchable(text: $searchText, prompt: "Поиск города")
                .overlay {
                    if filteredCities.isEmpty {
                        VStack {
                            Spacer()
                            Text("Город не найден")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                    }
                }
            }
        }
        .background(Color("YPWhite"))
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedCity) { city in
            StationSearchView(city: city) { station in
                onSelect(station)
            }
        }
        .task {
            await loadCities()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
    
    private func loadCities() async {
        isLoading = true
        loadError = nil
        
        do {
            let allStations = try await StationsRepository.shared.loadStations()
            
            let stationsWithSettlement = allStations.filter { station in
                guard let settlementTitle = station.settlementTitle else {
                    return false
                }
                return !settlementTitle.isEmpty
            }
            
            let groupedByCity = Dictionary(
                grouping: stationsWithSettlement,
                by: { station in
                    station.settlementTitle ?? ""
                }
            )
            
            var resultCities: [StationChoice] = []
            
            for (cityTitle, stations) in groupedByCity {
                guard let firstStation = stations.first else { continue }
                
                let city = StationChoice(
                    title: cityTitle,
                    yandexCode: firstStation.yandexCode,
                    settlementTitle: cityTitle
                )
                
                resultCities.append(city)
            }
            
            cities = sortCitiesByPriority(resultCities)
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet {
                loadError = .noInternet
            } else {
                loadError = .server
            }
        } catch {
            loadError = .server
        }
        
        isLoading = false
    }
    
    private func sortCitiesByPriority(_ cities: [StationChoice]) -> [StationChoice] {
        let priorities = Dictionary(
            uniqueKeysWithValues: popularCitiesOrder.enumerated().map { ($1, $0) }
        )
        
        return cities.sorted { lhs, rhs in
            let leftPriority = priorities[lhs.title]
            let rightPriority = priorities[rhs.title]
            
            switch (leftPriority, rightPriority) {
            case let (left?, right?):
                return left < right
            case (_?, nil):
                return true
            case (nil, _?):
                return false
            case (nil, nil):
                return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
        }
    }
}
