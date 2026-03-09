import SwiftUI

struct StoryViewerView: View {
    
    let startIndex: Int
    @Environment(\.dismiss) private var dismiss
    @State private var index: Int = 0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $index) {
                ForEach(0..<Story.mock.count, id: \.self) { i in
                    ZStack {
                        Rectangle()
                            .fill(.black.opacity(0.92))
                            .ignoresSafeArea()
                        
                        VStack(spacing: 12) {
                            Text(Story.mock[i].title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Полноразмерные изображения подключим позже")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.white.opacity(0.15))
                    .clipShape(Circle())
            }
            .padding(.top, 14)
            .padding(.trailing, 14)
        }
        .onAppear {
            index = min(max(0, startIndex), Story.mock.count - 1)
        }
    }
}

#Preview {
    StoryViewerView(startIndex: 0)
}
