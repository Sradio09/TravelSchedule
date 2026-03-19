import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                settingsRow(height: 60) {
                    Text("Темная тема")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color("YPBlack"))

                    Spacer()

                    Toggle("", isOn: $viewModel.isDarkTheme)
                        .labelsHidden()
                        .fixedSize()
                        .tint(Color("YPBlueUniversal"))
                }

                Button {
                    viewModel.openUserAgreement()
                } label: {
                    settingsRow(height: 60) {
                        Text("Пользовательское соглашение")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(Color("YPBlack"))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color("YPBlack"))
                    }
                }
                .buttonStyle(.plain)
            }
            .background(Color("YPWhite"))
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 8) {
                Text(viewModel.apiDescription)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color("YPBlack"))

                Text(viewModel.versionDescription)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color("YPBlack"))
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color("YPWhite").ignoresSafeArea())
        .fullScreenCover(isPresented: $viewModel.showUserAgreement) {
            UserAgreementView()
        }
    }

    private func settingsRow<Content: View>(height: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            content()
        }
        .frame(height: height)
        .padding(.horizontal, 16)
    }
}

#Preview {
    SettingsView()
}
