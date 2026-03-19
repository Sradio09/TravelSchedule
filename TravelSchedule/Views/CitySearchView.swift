import SwiftUI

struct CitySearchView: View {
    let title: String
    let onSelect: @Sendable (StationChoice) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CitySearchViewModel()
    @State private var selectedCity: StationChoice?

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                VStack(spacing: 12) {
                    Spacer()
                    ProgressView()
                    Text("Загружаем города…")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Spacer()
                }

            case .error(let loadError):
                LoadErrorView(error: loadError)

            case .success:
                List(viewModel.filteredCities) { city in
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
                .searchable(text: $viewModel.searchText, prompt: "Поиск города")
                .overlay {
                    if viewModel.filteredCities.isEmpty {
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
            await viewModel.loadCities()
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
}
