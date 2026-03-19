import SwiftUI

struct StationSearchView: View {
    let city: StationChoice
    let onSelect: @Sendable (StationChoice) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: StationSearchViewModel

    init(city: StationChoice, onSelect: @escaping @Sendable (StationChoice) -> Void) {
        self.city = city
        self.onSelect = onSelect
        _viewModel = StateObject(wrappedValue: StationSearchViewModel(city: city))
    }

    var body: some View {
        Group {
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .error(let error):
                LoadErrorView(error: error)
            case .success:
                stationsListView
            }
        }
        .background(Color("YPWhite"))
        .navigationTitle("Выбор станции")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadStations()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
            Text("Загружаем станции…")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var stationsListView: some View {
        List(viewModel.filteredStations) { station in
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
        .searchable(text: $viewModel.searchText, prompt: "Поиск станции")
        .overlay {
            if viewModel.filteredStations.isEmpty {
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
