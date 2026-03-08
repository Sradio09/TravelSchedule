import SwiftUI

struct NoInternetView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image("NoInternet")
                .resizable()
                .scaledToFit()
                .frame(width: 223, height: 223)

            Text("Нет интернета")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color("YPBlack"))

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("YPWhite"))
    }
}

#Preview {
    NoInternetView()
}
