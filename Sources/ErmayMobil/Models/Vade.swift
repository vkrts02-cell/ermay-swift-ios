import Foundation

public struct VadeItem: Identifiable, Codable, Hashable {
    public var id: String
    public var cariId: String?
    public var cariUnvan: String
    public var faturaId: String?
    public var faturaNo: String?
    public var vadeTarihi: String
    public var tutar: Double
    public var kalanTutar: Double
    public var tip: String // "ALACAK" veya "BORC"
    public var gecikmeGun: Int
    
    public init(
        id: String = UUID().uuidString,
        cariId: String? = nil,
        cariUnvan: String,
        faturaId: String? = nil,
        faturaNo: String? = nil,
        vadeTarihi: String,
        tutar: Double,
        kalanTutar: Double,
        tip: String = "ALACAK",
        gecikmeGun: Int = 0
    ) {
        self.id = id
        self.cariId = cariId
        self.cariUnvan = cariUnvan
        self.faturaId = faturaId
        self.faturaNo = faturaNo
        self.vadeTarihi = vadeTarihi
        self.tutar = tutar
        self.kalanTutar = kalanTutar
        self.tip = tip
        self.gecikmeGun = gecikmeGun
    }
}

