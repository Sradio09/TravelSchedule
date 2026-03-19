import SwiftUI

struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = UserAgreementViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.sections, id: \.self) { section in
                    Text(section)
                        .font(
                            .system(
                                size: viewModel.isHeader(section) ? 24 : 17,
                                weight: viewModel.isHeader(section) ? .bold : .regular
                            )
                        )
                        .foregroundStyle(Color("YPBlack"))
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .background(Color("YPWhite").ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color("YPBlack"))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        UserAgreementView()
    }
}
