import SwiftUI

struct ServerErrorView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image("ServerError")
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)

            Text("Ошибка сервера")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color("YPBlack"))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("YPWhite"))
    }
}

#Preview {
    ServerErrorView()
}
