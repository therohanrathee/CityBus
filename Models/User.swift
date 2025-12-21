import Foundation
import SwiftData

@Model
final class User {
    var email: String
    var phoneNumber: String
    var createdAt: Date

    init(email: String, phoneNumber: String, createdAt: Date = Date()) {
        self.email = email
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
    }
}
