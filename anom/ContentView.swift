//
//  ContentView.swift
//  anom
//
//  Created by 中村隼人 on 2021/05/26.
//

import SwiftUI


struct ContentView: View {
    @State var sheetPresented = false
    @State var WantToDoSheet = false
    
    var clManagerX = CLManager(calendar: Calendar.current, minimumDate: Date(), maximumDate: Date().addingTimeInterval(60*60*24*365))
    
    var body: some View {
        
        VStack (spacing: 15) {
            
            Button(action: { self.sheetPresented.toggle() }) {
                Text("Mood Tracker").foregroundColor(.blue)
            }
            .font(.largeTitle)
            .sheet(isPresented: self.$sheetPresented, content: {
                    CLViewController(isPresented: self.$sheetPresented, clManager: self.clManagerX)})
            Text(self.getTextFromDate(date: self.clManagerX.selectedDate))
            
            
            Button(action: { self.WantToDoSheet.toggle() }) {
                Text("Write Want to do").foregroundColor(.blue)
            }
            .font(.largeTitle)
            .sheet(isPresented: self.$WantToDoSheet, content: {
                    WantToDo()})
            
        }
        
    }
    
    func getTextFromDate(date: Date!) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "M-d-yyyy"
        return date == nil ? "" : formatter.string(from: date)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        
    }
}

//WantToDoView
struct WantToDo: View{
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @State var newItem:String = ""
    @State var selectedDate = Date().addingTimeInterval(60*60*24)
    @State var formatedDate = "yyyy/M/d"
    let dateFormatter = DateFormatter()
    
    
    @FetchRequest(
        entity: WantToDoData.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WantToDoData.date, ascending: true)],
        predicate: nil,
        animation: .default
    ) private var wantToDoData: FetchedResults<WantToDoData>
    
    var body: some View{
        
                
        NavigationView{
            VStack{
                
                HStack{
                    TextField("明日やりたいことを記入してください", text:$newItem).textFieldStyle(RoundedBorderTextFieldStyle()).frame(width:300)
                    
                    Button(action:{
                        /*dateFormatter.dateFormat = "yyyy/M/d"
                        dateFormatter.dateStyle = .short
                        dateFormatter.timeStyle = .none*/

                        
                        if(self.newItem != ""){
                           //formatedDate = dateFormatter.string(from: selectedDate)
                            self.addItem(date:formatedDate, wantToDo:self.newItem)
                            self.newItem = ""
                        }
                        
                    }){
                        ZStack{
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: 50, height: 30)
                                .foregroundColor(.green)
                            
                            Text("追加").foregroundColor(.white)
                        }
                    }
                }
                
                HStack{
                    Text("明日の日付")
                    DatePicker(selection: $selectedDate, displayedComponents:.date){
                        Text("Date")
                    }.labelsHidden()
                }
                
                
                HStack{
                    Text("明日やりたいこと").font(.title).padding(.leading)
                    Spacer()
                }
                List{
                    ForEach(wantToDoData){wantToDo in
                        
                        HStack{
                            Text("\(wantToDo.date!)")
                            Text("\(wantToDo.wantToDo!)")
                            Image(systemName: wantToDo.checked ? "checkmark.circle.fill" : "circle")
                            
                            Spacer()
                            
                        }
                        
                        Spacer()
                        
                    }
                }
            }
            .navigationBarItems(trailing:  Button(action:{
                self.presentationMode.wrappedValue.dismiss()
            })
            {
                Text("閉じる")
            })
            .navigationBarTitle("明日やりたいことの追加")
        }
        //navigation view
    }
    //body:some view
    
    
    private func addItem(date:String,wantToDo:String) {
        withAnimation {
            /// 新規レコードの作成
            let newItem = WantToDoData(context: viewContext)
            newItem.date = date
            newItem.wantToDo = wantToDo
            newItem.checked = false
            
            /// データベースの保存
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }//addItem
}
//WantToDoView


//InputMoodView
struct InputMood:View{
    @Environment (\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var clManager:CLManager
    
    @FetchRequest(
        entity: MoodData.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \MoodData.dateKey, ascending: true)],
        predicate: nil,
        animation: .default
    ) private var moodData: FetchedResults<MoodData>
    
    var body: some View{
        let colors:[Color] = [
            Color(red: convertCol(col:127), green: convertCol(col:191), blue: convertCol(col:255)),
            Color(red: convertCol(col:127), green: convertCol(col:255), blue: convertCol(col:255)),
            Color(red: convertCol(col:127), green: convertCol(col:255), blue: convertCol(col:127)),
            Color(red: convertCol(col:255), green: convertCol(col:255), blue: convertCol(col:127)),
            Color(red: convertCol(col:255), green: convertCol(col:191), blue: convertCol(col:127)),
        ]
        
        NavigationView{
            VStack{
                Text("今日の気分を教えてください").font(.title)
                
                HStack(){
                    Text("bad").font(.body).padding(.leading,58)
                    
                    Spacer()
                    Text("good").font(.body).padding(.trailing,55)
                    
                }
                HStack{
                    ForEach(0..<colors.count){ num in
                        Button(action:{
                            self.addItem(date: clManager.selectedDate, mood: num)
                            
                        }){
                            
                            Circle()
                                .frame(width:50, height:50)
                                .foregroundColor(colors[num])
                        }
                    }
                }
            }
        }
    }
    
    func convertCol(col:Int)->Double{
        let rgb:Double = Double(col/255)
        return rgb
    }
    
    
    
    private func addItem(date:Date,mood:Int) {
        var c = 0
        for md in moodData{
            if md.dateKey == date{
                viewContext.delete(moodData[c])
            }
            c += 1
        }
        withAnimation {
            /// 新規レコードの作成
            let newItem = MoodData(context: viewContext)
            newItem.dateKey = date
            newItem.mood = Int64(mood)
            
            /// データベースの保存
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
//InputMoodView

//CLCell
struct CLCell:View{
    @Environment(\.managedObjectContext) private var viewContext
    var clDate:CLDate
    var cellWidth:CGFloat
    
    
    @FetchRequest(
        entity: MoodData.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \MoodData.dateKey, ascending: true)],
        predicate: nil,
        animation: .default
    ) private var moodData: FetchedResults<MoodData>
    
    var body: some View{
        Text( clDate.getText() )
            .fontWeight( clDate.getFontWeight() )
            .foregroundColor(self.setColor())
            .frame( width:cellWidth, height:cellWidth )
            .font( .system(size:20) )
            .cornerRadius( cellWidth/2 )
        
    }
    
    func setColor()->Color?{
        var col = Color.black
        for md in moodData {
            if md.dateKey == clDate.date {
                if md.mood == 0 {
                    col = Color(red: 0.0, green: 0.0, blue: 1.0)
                }
                else if md.mood == 1{
                    col = Color(red: 0.0, green: 1.0, blue: 1.0)
                }
                else if md.mood == 2{
                    col = Color(red: 0.0, green: 1.0, blue: 0.0)
                }
                else if md.mood == 3{
                    col = Color(red: 1.0, green: 1.0, blue: 0.0)
                }
                else if md.mood == 4{
                    col = Color(red: 1.0, green: 0.0, blue: 0.0)
                }
            }
        }
        return col
    }
    
}
//CLCell

//CLDate
struct CLDate{
    var date:Date
    let clManager:CLManager
    var inputMood:InputMood
    
    
    
    var isToday:Bool = false
    var isSelected:Bool = false
    
    init( date:Date, clManager:CLManager, isToday:Bool, isSelected:Bool ,inputMood:InputMood) {
        self.date = date
        self.clManager = clManager
        self.isToday = isToday
        self.isSelected = isSelected
        self.inputMood = inputMood
        
    }
    
    
    
    
    
    func getText()->String{
        let day = formatDate( date:date, calendar:self.clManager.calendar )
        return day
    }
    
    func getFontWeight()->Font.Weight{
        var fontWeight = Font.Weight.medium
        
        if isSelected{
            fontWeight = Font.Weight.heavy
        }else if isToday{
            fontWeight = Font.Weight.heavy
        }
        return fontWeight
    }
    
    /*func getColor() -> Color? {
     let col = Color.black
     
     
     return col
     }*/
    
    
    
    
    func formatDate( date:Date, calendar:Calendar )->String{
        let formatter = dateFormatter()
        return stringFrom( date:date, formatter:formatter, calendar:calendar )
    }
    
    func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "d"
        return formatter
    }
    
    func stringFrom( date:Date, formatter:DateFormatter, calendar:Calendar ) -> String {
        if formatter.calendar != calendar{
            formatter.calendar = calendar
        }
        return formatter.string(from: date)
    }
    
    func getTextFromDate(date: Date!) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "M-d-yyyy"
        return date == nil ? "" : formatter.string(from: date)
    }
    
    
}
//CLDate


//CLViewController
struct CLViewController: View{
    @Binding var isPresented:Bool
    @ObservedObject var clManager:CLManager
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View{
        Group{
            List{
                ForEach( 0..<numberOfMonths() ){
                    index in CLMonth( isPresented:self.$isPresented, clManager:clManager, monthOffset:index)
                }
                Divider()
            }
        }
    }
    
    func numberOfMonths() -> Int {
        return clManager.calendar.dateComponents(
            [.month], from:clManager.minimumDate, to:CLMaximumDateMonthLastDay()
        ).month!+1
    }
    
    func CLMaximumDateMonthLastDay() -> Date {
        var components = clManager.calendar.dateComponents( [ .year, .month, .day ], from:clManager.maximumDate )
        components.month! += 1
        components.day = 0
        return clManager.calendar.date( from:components )!
    }
}
//CLViewController


//CLManager
class CLManager : ObservableObject {
    
    @Published var calendar = Calendar.current
    @Published var minimumDate: Date = Date()
    @Published var maximumDate: Date = Date()
    @Published var selectedDates: [Date] = [Date]()
    @Published var selectedDate: Date! = nil
    
    
    
    init(calendar: Calendar, minimumDate: Date, maximumDate: Date, selectedDates: [Date] = [Date]()) {
        self.calendar = calendar
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.selectedDates = selectedDates
    }
    
    func selectedDatesContains(date: Date) -> Bool {
        if let _ = self.selectedDates.first(where: { calendar.isDate($0, inSameDayAs: date) }) {
            return true
        }
        return false
    }
    
    
    func selectedDatesFindIndex(date: Date) -> Int? {
        return self.selectedDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) })
    }
    
}
//CLManager


//CLMonth
struct CLMonth: View {
    
    @Binding var isPresented: Bool
    @ObservedObject var clManager: CLManager
    @State var showInputMoodSheet: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    
    let monthOffset: Int
    let calendarUnitYMD = Set<Calendar.Component>([.year, .month, .day])
    let daysPerWeek = 7
    var monthsArray: [[Date]] {
        monthArray()
    }
    
    let cellWidth = CGFloat(32)
    
    //@State var showTime = false
    
    var body: some View {
        ScrollView(.horizontal){
            VStack(alignment: HorizontalAlignment.center, spacing: 10){
                Text(getMonthHeader())
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(monthsArray, id: \.self) { row in
                        HStack() {
                            ForEach(row, id: \.self) { column in
                                HStack() {
                                    Spacer()
                                    if self.isThisMonth(date: column) {
                                        CLCell(clDate: CLDate(
                                            date: column,
                                            clManager: self.clManager,
                                            isToday: self.isToday(date: column),
                                            isSelected: self.isSpecialDate(date: column),
                                            inputMood: InputMood( clManager: clManager)
                                        ),
                                        cellWidth: self.cellWidth)
                                        .onTapGesture { self.dateTapped(date: column)
                                            showInputMoodSheet = true
                                        }
                                        .sheet(isPresented: self.$showInputMoodSheet, content: {InputMood(
                                                clManager: clManager)})
                                    } else {
                                        Text("").frame(width: self.cellWidth, height: self.cellWidth)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func isThisMonth(date: Date) -> Bool {
        return self.clManager.calendar.isDate(date, equalTo: firstOfMonthForOffset(), toGranularity: .month)
    }
    
    func dateTapped(date: Date) {
        
        self.clManager.selectedDate = date
        
    }
    
    func monthArray() -> [[Date]] {
        var rowArray = [[Date]]()
        for row in 0 ..< (numberOfDays(offset: monthOffset) / 7) {
            var columnArray = [Date]()
            for column in 0 ... 6 {
                let abc = self.getDateAtIndex(index: (row * 7) + column)
                columnArray.append(abc)
            }
            rowArray.append(columnArray)
        }
        return rowArray
    }
    
    func getMonthHeader() -> String {
        let headerDateFormatter = DateFormatter()
        headerDateFormatter.calendar = clManager.calendar
        headerDateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy LLLL", options: 0, locale: clManager.calendar.locale)
        
        return headerDateFormatter.string(from: firstOfMonthForOffset()).uppercased()
    }
    
    func getDateAtIndex(index: Int) -> Date {
        let firstOfMonth = firstOfMonthForOffset()
        let weekday = clManager.calendar.component(.weekday, from: firstOfMonth)
        var startOffset = weekday - clManager.calendar.firstWeekday
        startOffset += startOffset >= 0 ? 0 : daysPerWeek
        var dateComponents = DateComponents()
        dateComponents.day = index - startOffset
        
        return clManager.calendar.date(byAdding: dateComponents, to: firstOfMonth)!
    }
    
    func numberOfDays(offset : Int) -> Int {
        let firstOfMonth = firstOfMonthForOffset()
        let rangeOfWeeks = clManager.calendar.range(of: .weekOfMonth, in: .month, for: firstOfMonth)
        
        return (rangeOfWeeks?.count)! * daysPerWeek
    }
    
    func firstOfMonthForOffset() -> Date {
        var offset = DateComponents()
        offset.month = monthOffset
        
        return clManager.calendar.date(byAdding: offset, to: CLFirstDateMonth())!
    }
    
    func CLFormatDate(date: Date) -> Date {
        let components = clManager.calendar.dateComponents(calendarUnitYMD, from: date)
        
        return clManager.calendar.date(from: components)!
    }
    
    func CLFormatAndCompareDate(date: Date, referenceDate: Date) -> Bool {
        let refDate = CLFormatDate(date: referenceDate)
        let clampedDate = CLFormatDate(date: date)
        return refDate == clampedDate
    }
    
    func CLFirstDateMonth() -> Date {
        var components = clManager.calendar.dateComponents(calendarUnitYMD, from: clManager.minimumDate)
        components.day = 1
        
        return clManager.calendar.date(from: components)!
    }
    
    
    func isToday(date: Date) -> Bool {
        return CLFormatAndCompareDate(date: date, referenceDate: Date())
    }
    
    func isSpecialDate(date: Date) -> Bool {
        return isSelectedDate(date: date)
    }
    
    
    
    func isSelectedDate(date: Date) -> Bool {
        if clManager.selectedDate == nil {
            return false
        }
        return CLFormatAndCompareDate(date: date, referenceDate: clManager.selectedDate)
    }
    
}
//CLMonth
