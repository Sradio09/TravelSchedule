import SwiftUI

struct StationSearchView: View {
    
    let city: StationChoice
    let onSelect: (StationChoice) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var stations: [StationChoice] = []
    @State private var isLoading = true
    @State private var loadError: LoadError?
    
    enum LoadError {
        case noInternet
        case server
    }
    
    private var filteredStations: [StationChoice] {
        guard !searchText.isEmpty else { return stations }
        
        return stations.filter { station in
            station.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 12) {
                    Spacer()
                    ProgressView()
                    Text("Загружаем станции…")
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
                List(filteredStations) { station in
                    Button {
                        onSelect(station)
                        dismiss()
                    } label: {
                        HStack {
                            Text(station.title)
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
                .searchable(text: $searchText, prompt: "Поиск станции")
                .overlay {
                    if filteredStations.isEmpty {
                        VStack {
                            Spacer()
                            
                            Text("Станция не найдена")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color("YPBlack"))
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .background(Color("YPWhite"))
        .navigationTitle("Выбор станции")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadStations()
        }
    }
    
    private func loadStations() async {
        isLoading = true
        loadError = nil
        
        do {
            let allStations = try await StationsRepository.shared.loadStations()
            
            let cityStations = allStations.filter { station in
                station.settlementTitle == city.title
            }
            
            stations = cityStations.sorted { lhs, rhs in
                lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
            }
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
}
