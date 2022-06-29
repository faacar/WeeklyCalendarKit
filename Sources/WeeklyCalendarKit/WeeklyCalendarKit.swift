import SwiftUI

public struct WeeklyCalendarKit<Header: View, Content: View>: View {
    private var calendar: Calendar
    @Binding private var date: Date
    private let header: (Date) -> Header
    private let content: (Date) -> Content
    
    private let daysInWeek = 7
    
    public init(
        calendar: Calendar,
        date: Binding<Date>,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder content: @escaping (Date) -> Content
    ) {
        self.calendar = calendar
        self._date = date
        self.header = header
        self.content = content
    }
    
    public var body: some View {
        
        let days = makeDays()
        
        VStack {
            
            header(date)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                ForEach(days.prefix(daysInWeek), id: \.self) { date in
                    VStack {
                        content(date)
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            //left
                                guard let newDate = calendar.date(
                                    byAdding: .weekOfMonth,
                                    value: 1,
                                    to: date
                                ) else { return }
                                date = newDate
                        }
                        
                        if value.translation.width > 0 {
                            //right
                            guard let newDate = calendar.date(
                                byAdding: .weekOfMonth,
                                value: -1,
                                to: date
                            ) else { return }
                            date = newDate
                        }
                    }
            )

            Divider()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
}




//MARK: Helper
private extension WeeklyCalendarKit {
    func makeDays() -> [Date] {
        guard let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: date),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: firstWeek.end - 1)
        else {
            return []
        }
        
        
        let dateInterval = DateInterval(start: firstWeek.start, end: lastWeek.end)
        return calendar.generateDays(for: dateInterval)
        
    }
}


private extension Calendar {
    func generateDates(for dateInterval: DateInterval, mathcing components: DateComponents) -> [Date] {
        var dates = [dateInterval.start]
        
        enumerateDates(
            startingAfter: dateInterval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { result, exactMatch, stop in
            
            guard let date = result else { return }
            
            guard date < dateInterval.end else {
                stop = true
                return
            }
            
            dates.append(date)
        }
        
        return dates
        
    }
    
    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(
            for: dateInterval,
               mathcing: dateComponents(
                [.hour, .minute, .second],
                from: dateInterval.start)
        )
    }
    
    
}

private extension Date {
    
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: self)) ?? self
    }
    
}


private extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
        self.locale = Locale(identifier: "en")
    }
}
