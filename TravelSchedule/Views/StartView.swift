import SwiftUI

struct StartView: View {
    
    @State private var fromStation: StationChoice?
    @State private var toStation: StationChoice?
    
    @State private var showStoryViewer = false
    @State private var selectedStoryIndex = 0
    
    @State private var activeSelection: SelectionType?
    @State private var showSchedule = false
    
    private var canSearch: Bool {
        fromStation != nil && toStation != nil
    }
    
    private var fromTitle: String {
        fromStation?.title ?? "Откуда"
    }
    
    private var toTitle: String {
        toStation?.title ?? "Куда"
    }
    
    private enum SelectionType: Identifiable {
        case from
        case to
        
        var id: Int {
            switch self {
            case .from: return 0
            case .to: return 1
            }
        }
        
        var screenTitle: String {
            "Выбор города"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            storiesPanel
            
            mainContent
                .padding(.top, 44)
            
            Spacer()
        }
        .background(Color("YPWhite"))
        .fullScreenCover(item: $activeSelection) { selection in
            citySelectionScreen(for: selection)
        }
        .navigationDestination(isPresented: $showSchedule) {
            if let fromStation, let toStation {
                ScheduleView(from: fromStation, to: toStation)
            }
        }
        .fullScreenCover(isPresented: $showStoryViewer) {
            StoryViewerView(startIndex: selectedStoryIndex)
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 12) {
            fromToFields
            
            if canSearch {
                Button {
                    showSchedule = true
                } label: {
                    Text("Найти")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 150, height: 60)
                        .background(Color("YPBlueUniversal"))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func citySelectionScreen(for selection: SelectionType) -> some View {
        NavigationStack {
            CitySearchView(title: selection.screenTitle) { station in
                switch selection {
                case .from:
                    fromStation = station
                case .to:
                    toStation = station
                }
                activeSelection = nil
            }
        }
    }
    
    private var storiesPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(Story.mock.enumerated()), id: \.offset) { index, _ in
                    Button {
                        selectedStoryIndex = index
                        showStoryViewer = true
                    } label: {
                        storyPreviewPlaceholder(index: index)
                            .frame(width: 92, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
    }
    
    private func storyPreviewPlaceholder(index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.blue.opacity(0.15))
            
            Text("\(index + 1)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.blue)
        }
    }
    
    private var fromToFields: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("YPBlueUniversal"))
                .frame(height: 128)
            
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Button {
                        activeSelection = .from
                    } label: {
                        fieldRow(
                            text: fromTitle,
                            isPlaceholder: fromStation == nil
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        activeSelection = .to
                    } label: {
                        fieldRow(
                            text: toTitle,
                            isPlaceholder: toStation == nil
                        )
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .background(Color("YPWhiteUniversal"))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.leading, 16)
                .padding(.vertical, 16)
                .padding(.trailing, 68)
                
                Spacer(minLength: 0)
            }
            
            Button {
                swapStations()
            } label: {
                Image("change")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
            .padding(.trailing, 16)
        }
    }
    
    private func fieldRow(text: String, isPlaceholder: Bool) -> some View {
        HStack {
            Text(text)
                .foregroundStyle(isPlaceholder ? Color("YPGray") : Color("YPBlackUniversal"))
            Spacer()
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
    }
    
    private func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
}

#Preview {
    NavigationStack {
        StartView()
    }
}
