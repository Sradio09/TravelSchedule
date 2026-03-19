import SwiftUI

struct StartView: View {
    @StateObject private var viewModel = StartViewModel()

    var body: some View {
        VStack(spacing: 0) {
            storiesPanel

            mainContent
                .padding(.top, 44)

            Spacer()
        }
        .background(Color("YPWhite").ignoresSafeArea())
        .fullScreenCover(item: $viewModel.activeSelection) { selection in
            citySelectionScreen(for: selection)
        }
        .navigationDestination(isPresented: $viewModel.showSchedule) {
            if let fromStation = viewModel.fromStation, let toStation = viewModel.toStation {
                ScheduleView(from: fromStation, to: toStation)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showStoryViewer, onDismiss: {
            viewModel.handleStoryDismiss()
        }) {
            StoryViewerView(startIndex: viewModel.selectedStoryIndex, stories: viewModel.stories) { story in
                StorySeenStore.markSeen(story)
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 12) {
            fromToFields

            if viewModel.canSearch {
                Button {
                    viewModel.openSchedule()
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

    private func citySelectionScreen(for selection: StartViewModel.SelectionType) -> some View {
        NavigationStack {
            CitySearchView(title: selection.screenTitle) { station in
                Task { @MainActor in
                    viewModel.setStation(station, for: selection)
                }
            }
        }
    }

    private var storiesPanel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(viewModel.stories.enumerated()), id: \.element.id) { index, story in
                    Button {
                        viewModel.selectStory(at: index)
                    } label: {
                        storyPreview(story)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.vertical, 4)
        }
        .frame(height: 172)
        .id(viewModel.storyRefreshToken)
    }

    private func storyPreview(_ story: Story) -> some View {
        let isSeen = StorySeenStore.isSeen(story)

        return ZStack(alignment: .bottomLeading) {
            Image(story.imageName)
                .resizable()
                .scaledToFill()
                .scaleEffect(x: story.imageName == "story_1" ? -1 : 1, y: 1)
                .frame(width: 92, height: 140)
                .clipped()
                .opacity(isSeen ? 0.5 : 1)

            LinearGradient(
                colors: [.clear, .black.opacity(0.72)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(width: 92, height: 140)

            Text(story.title)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .frame(width: 76, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
        }
        .frame(width: 92, height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isSeen ? .clear : Color("YPBlueUniversal"), lineWidth: 4)
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
                        viewModel.openSelection(.from)
                    } label: {
                        fieldRow(text: viewModel.fromTitle, isPlaceholder: viewModel.fromStation == nil)
                    }
                    .buttonStyle(.plain)

                    Button {
                        viewModel.openSelection(.to)
                    } label: {
                        fieldRow(text: viewModel.toTitle, isPlaceholder: viewModel.toStation == nil)
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
                viewModel.swapStations()
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
}

#Preview {
    NavigationStack {
        StartView()
    }
}
