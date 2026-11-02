import Foundation

public struct MusteriRisk: Identifiable, Codable, Sendable {
    public var id: String
    public var cariId: String?
    public var unvan: String
    public var riskLimiti: Double
    public var guncelBakiye: Double
    public var vadesiGecenBakiye: Double
    public var gecikmeGunu: Int
    
    public var kalanLimit: Double {
        return max(0, riskLimiti - guncelBakiye)
    }
    
    public var riskOrani: Double {
        guard riskLimiti > 0 else { return 100.0 }
        return min(100.0, (guncelBakiye / riskLimiti) * 100.0)
    }
    
    public var riskSeviyesi: String {
        if guncelBakiye > riskLimiti && riskLimiti > 0 {
            return "LİMİT AŞIMI"
        } else if riskOrani > 75 || gecikmeGunu > 15 {
            return "YÜKSEK RİSK"
        } else if riskOrani > 40 || gecikmeGunu > 0 {
            return "ORTA RİSK"
        } else {
            return "GÜVENLİ"
        }
    }
    
    public init(
        id: String = UUID().uuidString,
        cariId: String? = nil,
        unvan: String,
        riskLimiti: Double = 50000.0,
        guncelBakiye: Double = 0.0,
        vadesiGecenBakiye: Double = 0.0,
        gecikmeGunu: Int = 0
    ) {
        self.id = id
        self.cariId = cariId
        self.unvan = unvan
        self.riskLimiti = riskLimiti
        self.guncelBakiye = guncelBakiye
        self.vadesiGecenBakiye = vadesiGecenBakiye
        self.gecikmeGunu = gecikmeGunu
    }
}

