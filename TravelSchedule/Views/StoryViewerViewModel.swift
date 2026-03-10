import Foundation

@MainActor
final class StoryViewerViewModel: ObservableObject {
    @Published var selectedStoryIndex: Int
    @Published var selectedPageIndex: Int = 0

    let stories: [Story]

    init(startIndex: Int, stories: [Story]) {
        self.stories = stories
        self.selectedStoryIndex = min(max(startIndex, 0), max(stories.count - 1, 0))
    }

    var currentStory: Story? {
        guard stories.indices.contains(selectedStoryIndex) else { return nil }
        return stories[selectedStoryIndex]
    }

    var currentPagesCount: Int {
        currentStory?.pages.count ?? 0
    }

    var isLastPageInStory: Bool {
        selectedPageIndex >= currentPagesCount - 1
    }

    var isFirstPageInStory: Bool {
        selectedPageIndex == 0
    }

    var canShowPreviousStory: Bool {
        selectedStoryIndex > 0
    }

    var canShowNextStory: Bool {
        selectedStoryIndex < stories.count - 1
    }

    func markInitialStorySeen(onStorySeen: (Story) -> Void) {
        guard let currentStory else { return }
        onStorySeen(currentStory)
    }

    func showNextPageOrStory(onStorySeen: (Story) -> Void) -> Bool {
        guard stories.indices.contains(selectedStoryIndex) else { return false }

        if selectedPageIndex < currentPagesCount - 1 {
            selectedPageIndex += 1
            return true
        }

        let nextStoryIndex = selectedStoryIndex + 1
        guard stories.indices.contains(nextStoryIndex) else {
            return false
        }

        selectedStoryIndex = nextStoryIndex
        selectedPageIndex = 0
        onStorySeen(stories[nextStoryIndex])
        return true
    }

    func showPreviousPageOrStory(onStorySeen: (Story) -> Void) {
        guard stories.indices.contains(selectedStoryIndex) else { return }

        if selectedPageIndex > 0 {
            selectedPageIndex -= 1
            return
        }

        let previousStoryIndex = selectedStoryIndex - 1
        guard stories.indices.contains(previousStoryIndex) else { return }

        selectedStoryIndex = previousStoryIndex
        selectedPageIndex = max(stories[previousStoryIndex].pages.count - 1, 0)
        onStorySeen(stories[previousStoryIndex])
    }
}
