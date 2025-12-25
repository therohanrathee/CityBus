import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    // 👇 PASTE YOUR KEYS FROM SUPABASE DASHBOARD HERE
    // Go to: Supabase Dashboard -> Project Settings (Gear Icon) -> API
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "YOUR_PROJECT_URL_HERE")!,
        supabaseKey: "YOUR_ANON_PUBLIC_KEY_HERE"
    )

    private init() {}
}