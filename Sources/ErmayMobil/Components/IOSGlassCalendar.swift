import SwiftUI

public struct IOSGlassCalendar: View {
    @Binding public var selectedDate: Date
    public var markedDates: Set<String> // YYYY-MM-DD
    public var onDateSelected: ((Date) -> Void)?
    
    @State private var currentMonth: Date = Date()
    
    public init(
        selectedDate: Binding<Date>,
        markedDates: Set<String> = [],
        onDateSelected: ((Date) -> Void)? = nil
    ) {
        self._selectedDate = selectedDate
        self.markedDates = markedDates
        self.onDateSelected = onDateSelected
    }
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
    
    public var body: some View {
        GlassCard(cornerRadius: 18, padding: 16) {
            VStack(spacing: 14) {
                // Ay & Yıl Başlığı ve Geçiş Okları
                HStack {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                            .padding(8)
                            .background(Circle().fill(AppTheme.cardSecondary))
                    }
                    
                    Spacer()
                    
                    Text(monthYearString(from: currentMonth))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                            .padding(8)
                            .background(Circle().fill(AppTheme.cardSecondary))
                    }
                }
                
                // Haftanın Günleri Başlığı
                HStack {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppTheme.textMuted)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Günler Grid
                let days = generateDaysInMonth(for: currentMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(days, id: \.self) { date in
                        if let d = date {
                            let isSelected = calendar.isDate(d, inSameDayAs: selectedDate)
                            let isToday = calendar.isDateInToday(d)
                            let dateStr = AppFormatters.isoDate.string(from: d)
                            let isMarked = markedDates.contains(dateStr)
                            
                            Button {
                                selectedDate = d
                                onDateSelected?(d)
                            } label: {
                                VStack(spacing: 2) {
                                    Text("\(calendar.component(.day, from: d))")
                                        .font(.system(size: 13, weight: isSelected ? .bold : (isToday ? .bold : .regular)))
                                        .foregroundColor(isSelected ? .white : (isToday ? AppTheme.primary : AppTheme.textPrimary))
                                    
                                    Circle()
                                        .fill(isSelected ? .white : (isMarked ? AppTheme.warning : Color.clear))
                                        .frame(width: 4, height: 4)
                                }
                                .frame(width: 34, height: 34)
                                .background(
                                    Circle()
                                        .fill(isSelected ? AppTheme.primary : (isToday ? AppTheme.primary.opacity(0.15) : Color.clear))
                                )
                            }
                        } else {
                            Text("")
                                .frame(width: 34, height: 34)
                        }
                    }
                }
            }
        }
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date).capitalized
    }
    
    private func generateDaysInMonth(for date: Date) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
        let startOfMonth = monthInterval.start
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        // Pazartesi = 2, Pazar = 1 (tr_TR) -> Offset hesaplama
        let offset = (firstWeekday + 5) % 7
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        
        let range = calendar.range(of: .day, in: .month, for: date)!
        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(d)
            }
        }
        
        return days
    }
}

