import SwiftUI

struct StoryViewerView: View {
    let startIndex: Int
    let stories: [Story]
    let onStorySeen: (Story) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: StoryViewerViewModel

    private let storyCornerRadius: CGFloat = 40
    private let progressTopInset: CGFloat = 35
    private let progressHorizontalInset: CGFloat = 12
    private let closeTopSpacing: CGFloat = 16
    private let closeButtonSize: CGFloat = 30
    private let textHorizontalInset: CGFloat = 16
    private let textBottomInset: CGFloat = 98

    init(
        startIndex: Int,
        stories: [Story],
        onStorySeen: @escaping (Story) -> Void
    ) {
        self.startIndex = startIndex
        self.stories = stories
        self.onStorySeen = onStorySeen
        _viewModel = StateObject(
            wrappedValue: StoryViewerViewModel(startIndex: startIndex, stories: stories)
        )
    }

    var body: some View {
        ZStack {
            Color("YPBlackUniversal")
                .ignoresSafeArea()

            GeometryReader { geometry in
                let canvasSize = geometry.size
                let safeTop = geometry.safeAreaInsets.top
                let safeBottom = geometry.safeAreaInsets.bottom

                if let story = viewModel.currentStory {
                    let frame = storyFrame(in: canvasSize, safeTop: safeTop, safeBottom: safeBottom)

                    ZStack {
                        storyCard(story: story, frame: frame)
                            .id(story.id)
                            .transition(.move(edge: .trailing))
                    }
                    .overlay(alignment: .top) {
                        topOverlay(pagesCount: story.pages.count)
                    }
                }
            }
        }
        .task {
            viewModel.markInitialStorySeen(onStorySeen: onStorySeen)
        }
    }

    private func storyCard(story: Story, frame: CGRect) -> some View {
        let currentImageName = story.pages[safe: viewModel.selectedPageIndex] ?? story.imageName

        return ZStack(alignment: .bottomLeading) {
            storyImage(named: currentImageName, frame: frame)

            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showPreviousPageOrStory()
                    }

                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showNextPageOrStory()
                    }
            }
            .frame(width: frame.width, height: frame.height)

            VStack(alignment: .leading, spacing: 12) {
                Text(story.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(story.subtitle)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.white)
                    .lineLimit(3)
            }
            .padding(.horizontal, textHorizontalInset)
            .padding(.bottom, textBottomInset)
            .frame(width: frame.width, alignment: .leading)
        }
        .frame(width: frame.width, height: frame.height)
        .clipShape(RoundedRectangle(cornerRadius: storyCornerRadius, style: .continuous))
        .position(x: frame.midX, y: frame.midY)
    }

    private func storyImage(named imageName: String, frame: CGRect) -> some View {
        ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .scaleEffect(x: imageName == "story_1" ? -1 : 1, y: 1)
                .frame(width: frame.width, height: frame.height)
                .clipped()

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.15),
                    .black.opacity(0.75)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(width: frame.width, height: frame.height)
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private func topOverlay(pagesCount: Int) -> some View {
        VStack(spacing: closeTopSpacing) {
            HStack(spacing: 6) {
                ForEach(0..<pagesCount, id: \.self) { index in
                    Capsule()
                        .fill(index <= viewModel.selectedPageIndex ? Color("YPBlueUniversal") : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 6)
                }
            }

            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: closeButtonSize, height: closeButtonSize)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.top, progressTopInset)
        .padding(.horizontal, progressHorizontalInset)
        .transaction { transaction in
            transaction.animation = nil
        }
    }

    private func storyFrame(in canvas: CGSize, safeTop: CGFloat, safeBottom: CGFloat) -> CGRect {
        let topInset: CGFloat = 7
        let bottomInset: CGFloat = 17
        let targetAspectRatio: CGFloat = 9.0 / 16.0

        let height = canvas.height - topInset - bottomInset
        let width = min(canvas.width, height * targetAspectRatio)

        let originX = (canvas.width - width) / 2
        let originY = topInset

        return CGRect(
            x: originX,
            y: originY,
            width: width,
            height: height
        )
    }

    private func showNextPageOrStory() {
        let didContinue = viewModel.showNextPageOrStory(onStorySeen: onStorySeen)
        if !didContinue {
            dismiss()
        }
    }

    private func showPreviousPageOrStory() {
        viewModel.showPreviousPageOrStory(onStorySeen: onStorySeen)
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    StoryViewerView(startIndex: 0, stories: Story.mock) { _ in }
}
