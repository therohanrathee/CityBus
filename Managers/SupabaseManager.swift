import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    // 👇 PASTE YOUR KEYS FROM SUPABASE DASHBOARD HERE
    // Go to: Supabase Dashboard -> Project Settings (Gear Icon) -> API
    
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://uyulxqhsuqbddxpvzuvz.supabase.co")!,
        supabaseKey: "sb_publishable_2dd7TzqAIi1vB-27BkOMGg_XxzpKT3P"
    )

    private init() {}
}
