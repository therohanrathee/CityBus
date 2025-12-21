import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var phoneNumber: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "bus.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
                .padding(.bottom, 10)

            Text("Welcome to CityBus")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Please enter your details to continue.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .textInputAutocapitalization(.never)

                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            Button(action: saveUser) {
                Text("Continue")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundStyle(.white)
                    .cornerRadius(14)
            }
            .disabled(!isValid)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .interactiveDismissDisabled()
    }

    private var isValid: Bool {
        !email.isEmpty && !phoneNumber.isEmpty
    }

    private func saveUser() {
        let newUser = User(email: email, phoneNumber: phoneNumber)
        modelContext.insert(newUser)
        try? modelContext.save()
        dismiss()
    }
}
