import UIKit
import SwiftUI

class ViewControllerNoAI: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ViewControllerNoAI loaded")
        
        let hostingController = UIHostingController(rootView: ThermostatView(navigateHome: { [weak self] in
            self?.navigateBackToHome()  // Call navigateBackToHome function when the arrow is pressed
        }))
        addChild(hostingController)
        hostingController.view.frame = self.view.bounds
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    // Function to navigate back (pop or dismiss)
    func navigateBackToHome() {
        // If presented modally, dismiss it
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            // If it's part of a navigation controller, pop the current view controller
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// SwiftUI View
struct ThermostatView: View {
    var navigateHome: () -> Void
    
    // State variables
    @State private var currentTemperature: Double = 20
    @State private var sliderTemperature: Double = 22
    @State private var isHeating: Bool = true
    @State private var isPageEnabled: Bool = true // Controls whether the user can interact with the page
    @State private var isSettingsActive: Bool = false // For navigating to the settings screen
    
    // Constants for the ring
    private let minTemperature: Double = 10
    private let maxTemperature: Double = 30
    private let circleRadius: CGFloat = 150 // Radius of the outer circle

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    
                    // Top bar with back button, title, and settings icon
                    HStack {
                        Button(action: {
                            // Navigate to the home page when arrow is pressed
                            navigateHome()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .padding()
                        }
                        Spacer()

                        // Title in the center
                        Text("KITCHEN")
                            .font(.system(size: 40))  // Larger font size
                            .bold()
                            .multilineTextAlignment(.center)  // Ensure centered text
                            .padding(.top, -10)  // Move slightly upwards if needed for better alignment

                        Spacer()

                        // Settings icon in the top-right corner
                        NavigationLink(destination: SettingsView2()) {
                            Image(systemName: "gearshape.fill")
                                .font(.title)
                                .padding()
                        }
                    }
                    .padding([.leading, .trailing], 16)
                    
                    // Circular Temperature Display with a ring around it
                    ZStack {
                        GeometryReader { geometry in
                            ZStack {
                                Circle() // Outer ring
                                    .stroke(AngularGradient(gradient: Gradient(stops: [
                                        Gradient.Stop(color: Color.red.darker(), location: 0.0),
                                        Gradient.Stop(color: Color.blue.darker(), location: 0.5),
                                        Gradient.Stop(color: Color.red.darker(), location: 1.0)
                                    ]), center: .center, startAngle: .degrees(0), endAngle: .degrees(360)), lineWidth: 20)
                                    .frame(width: circleRadius * 2, height: circleRadius * 2)

                                Circle() // Inner circle (temperature display)
                                    .fill(Color.green)
                                    .frame(width: 250, height: 250)

                                VStack {
                                    Text("Currently:")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                    Text("\(String(format: "%.1f", currentTemperature))")
                                        .font(.system(size: 72))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }

                                // Small circle moving around the outer ring
                                Circle()
                                    .fill(colorForPositionOnRing(for: sliderTemperature))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        // Show temperature only if controls are enabled
                                        Text(isPageEnabled ? "\(String(format: "%.1f", sliderTemperature))" : "")
                                            .foregroundColor(.white)
                                            .font(.headline)
                                    )
                                    .position(circlePosition(for: sliderTemperature, in: geometry)) // Pass the geometry here
                            }
                        }
                    }
                    
                    // Manual Adjustment Slider
                    VStack {
                        Text("Manual Adjustment")
                            .font(.subheadline)
                        HStack {
                            Text("Min")
                            Slider(value: $sliderTemperature, in: minTemperature...maxTemperature, step: 0.5)
                                .disabled(!isPageEnabled) // Disable if toggle is off
                            Text("Max")
                        }
                        .padding(.horizontal)
                    }
                    
                    // Heating, Cooling, or OFF/Steady based on toggle state and temperature comparison
                    HStack {
                        if isPageEnabled {
                            if currentTemperature == sliderTemperature {
                                Text("Steady...")
                                    .foregroundColor(.green)
                                    .font(.headline)
                            } else {
                                Text(isHeating ? "Heating..." : "Cooling...")
                                    .foregroundColor(isHeating ? .red : .blue)
                                    .font(.headline)
                            }
                            Image(systemName: currentTemperature == sliderTemperature ? "pause.circle" : (isHeating ? "flame.fill" : "snowflake"))
                                .foregroundColor(currentTemperature == sliderTemperature ? .green : (isHeating ? .red : .blue))
                        } else {
                            Text("OFF")
                                .foregroundColor(.gray)
                                .font(.headline)
                            Image(systemName: "power")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer() // Pushes content up
                    
                    // Toggle Switch at the bottom with increased visibility
                    Toggle(isOn: $isPageEnabled) {
                        Text("Enable Controls")
                            .font(.title2)
                            .foregroundColor(isPageEnabled ? .green : .gray)
                            .bold()
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                    .padding(.horizontal)
                    .background(Color.white.opacity(1.0)) // Lighten the toggle area (no darkening)
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                }
                .padding()
                .onChange(of: sliderTemperature) { newValue in
                    updateHeatingCoolingStatus()
                }
                
                // Curtain effect when controls are disabled, without adding another toggle
                if !isPageEnabled {
                    Color.black.opacity(0.5) // Dims the page
                        .ignoresSafeArea()
                        .allowsHitTesting(false) // Prevents interaction with the rest of the UI
                }
            }
        }
    }
    
    // Function to update the heating/cooling status based on temperature comparison
    private func updateHeatingCoolingStatus() {
        isHeating = currentTemperature < sliderTemperature
    }
    
    // Function to calculate the position of the small temperature circle on the outer ring
    private func circlePosition(for temperature: Double, in geometry: GeometryProxy) -> CGPoint {
        // Limit angle range between -190 degrees (left) to 10 degrees (right)
        let angle = (temperature - minTemperature) / (maxTemperature - minTemperature) * 200 - 190
        let radians = angle * .pi / 180

        // Dynamically calculate the center of the circle based on available view size
        let viewWidth = geometry.size.width
        let viewHeight = geometry.size.height

        // Adjust the centerX and centerY to be relative to the view's size
        let centerX = viewWidth / 2 // Dynamically center in the middle of the view
        let centerY = viewHeight / 2 // Adjust the Y center based on available view height

        // Use the cos and sin of the angle for positioning along the circular path
        let x = centerX + circleRadius * cos(radians)
        let y = centerY + circleRadius * sin(radians)

        return CGPoint(x: x, y: y)
    }
    
    // Function to calculate the color for the small circle based on its position on the ring
    private func colorForPositionOnRing(for temperature: Double) -> Color {
        // Calculate the angle based on the temperature's position on the ring
        let ratio = (temperature - minTemperature) / (maxTemperature - minTemperature)
        let redComponent = ratio
        let blueComponent = 1.0 - ratio
        return Color(red: redComponent, green: 0.0, blue: blueComponent)
    }
}

// Extension to darken colors
extension Color {
    func darker() -> Color {
        return self.opacity(1) // Darken the color by keeping full opacity
    }
}



import SwiftUI

struct SettingsView2: View {
    @State private var locationControlEnabled: Bool = true
    @State private var energySavingModeEnabled: Bool = false
    @State private var suspendScheduleEnabled: Bool = false
    @State private var leavingTemperature: Double = 15.0
    @State private var arrivingTemperature: Double = 21.5
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with back button and title
            HStack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "house.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                Spacer()
                Image(systemName: "figure.walk")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Suspend Schedule Section
                    HStack {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 24))
                        Text("Suspend Schedule")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: $suspendScheduleEnabled)
                            .labelsHidden()
                            .onChange(of: suspendScheduleEnabled) { newValue in
                                saveSettings()
                            }
                    }
                    .padding(.horizontal)
                    
                    // Schedule Section with Conditional NavigationLink
                    VStack(alignment: .leading, spacing: 10) {
                        if suspendScheduleEnabled {
                            VStack(alignment: .leading, spacing: 10) {
                                // Weekdays bar
                                VStack(alignment: .leading) {
                                    Text("M, T, W, T, F")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    createScheduleBar(dayType: .weekday)
                                }
                                
                                // Weekends bar
                                VStack(alignment: .leading) {
                                    Text("SAT, SUN")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    createScheduleBar(dayType: .weekend)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.4)) // Darker background
                            .cornerRadius(10)
                        } else {
                            NavigationLink(destination: ScheduleDetailsView()) {
                                VStack(alignment: .leading, spacing: 10) {
                                    // Weekdays bar
                                    VStack(alignment: .leading) {
                                        Text("M, T, W, T, F")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        createScheduleBar(dayType: .weekday)
                                    }
                                    
                                    // Weekends bar
                                    VStack(alignment: .leading) {
                                        Text("SAT, SUN")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        createScheduleBar(dayType: .weekend)
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1)) // Normal background
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30) // Adds extra space before Location Control
                    
                    // Leaving Temperature
                    VStack(alignment: .leading) {
                        Text("WHEN LEAVING")
                            .font(.caption)
                            .fontWeight(.bold)
                        HStack {
                            Image(systemName: "thermometer")
                            Text("Temperature")
                            Spacer()
                            Text("\(leavingTemperature, specifier: "%.1f")°")
                            Slider(value: $leavingTemperature, in: 10...30, step: 0.1)
                                .frame(width: 150)
                                .onChange(of: leavingTemperature) { newValue in
                                    saveSettings()
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Arriving Temperature
                    VStack(alignment: .leading) {
                        Text("WHEN ARRIVING")
                            .font(.caption)
                            .fontWeight(.bold)
                        HStack {
                            Image(systemName: "thermometer")
                            Text("Temperature")
                            Spacer()
                            Text("\(arrivingTemperature, specifier: "%.1f")°")
                            Slider(value: $arrivingTemperature, in: 10...30, step: 0.1)
                                .frame(width: 150)
                                .onChange(of: arrivingTemperature) { newValue in
                                    saveSettings()
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Set your preferred temperatures for when you leave and return. The system adjusts automatically, maintaining comfort while optimizing energy use.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    

                    

                }
                .padding(.top)
                .onAppear{
                    loadSettings()
                }
            }
            .onDisappear{
                saveSettings()
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
    }
    
    // Schedule Bar UI Component
    private func createScheduleBar(dayType: DayType) -> some View {
        HStack(spacing: 1) {
            ForEach(0..<24) { hour in
                Rectangle()
                    .fill(self.colorForHour(hour: hour, dayType: dayType))
                    .frame(width: 10, height: 20)
            }
        }
        .cornerRadius(5)
    }
    
    // Function to determine color based on time of day
    private func colorForHour(hour: Int, dayType: DayType) -> Color {
        switch dayType {
        case .weekday:
            if (hour >= 6 && hour <= 9) || (hour >= 18 && hour <= 21) {
                return Color.orange
            } else {
                return Color.blue
            }
        case .weekend:
            if (hour >= 8 && hour <= 10) || (hour >= 16 && hour <= 20) {
                return Color.orange
            } else {
                return Color.blue
            }
        }
    }
    
    enum DayType {
        case weekday, weekend
    }
    
    // Settings Load and Save functions
    private func loadSettings() {
        if let settings = FileUtility.shared.readSettings(fileName: "settings_log.txt") {
            if let locationControl = settings["Location Control Enabled"] as? String {
                locationControlEnabled = locationControl == "true"
            }
            if let energySaving = settings["Energy Saving Mode Enabled"] as? String {
                energySavingModeEnabled = energySaving == "true"
            }
            if let leavingTemp = settings["Leaving Temperature"] as? String,
               let temp = Double(leavingTemp) {
                leavingTemperature = temp
            }
            if let arrivingTemp = settings["Arriving Temperature"] as? String,
               let temp = Double(arrivingTemp) {
                arrivingTemperature = temp
            }
            if let suspendSchedule = settings["Suspend Schedule Enabled"] as? String {
                suspendScheduleEnabled = suspendSchedule == "true"
            }
        }
    }
    
    private func saveSettings() {
        let settings = """
        Location Control Enabled: \(locationControlEnabled)
        Energy Saving Mode Enabled: \(energySavingModeEnabled)
        Suspend Schedule Enabled: \(suspendScheduleEnabled)
        Leaving Temperature: \(leavingTemperature)
        Arriving Temperature: \(arrivingTemperature)
        Changed At: \(Date())
        """
        FileUtility.shared.writeToFile(fileName: "settings_log.txt", content: settings + "\n")
    }
}

// Sample destination view for navigation


struct ScheduleDetailsView2: View {
    @AppStorage("programs") private var storedProgramsData: Data = Data() // Store the programs data
    @State private var programs: [Program] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Display each program
                ForEach(programs.indices, id: \.self) { index in
                    ProgramView(program: $programs[index], onDelete: {
                        deleteProgram(at: index) // Delete program when trash is clicked
                    })
                }
                
                // Add Program Button
                Button(action: {
                    addNewProgram()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Program")
                    }
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .onAppear {
            loadPrograms() // Load the programs when the view appears
        }
        .onChange(of: programs) { _ in
            savePrograms() // Save the programs whenever they change
        }
    }
    
    // Function to add a new program with default values
    private func addNewProgram() {
        let newProgram = Program(
            title: "PROGRAM \(programs.count + 1)",
            comfortPeriods: [
                ComfortPeriod(start: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!, end: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!)
            ],
            selectedDays: ["MO", "TU"], // Default selected days
            totalDuration: "3 hours"
        )
        programs.append(newProgram)
    }
    
    // Function to delete a program
    private func deleteProgram(at index: Int) {
        programs.remove(at: index)
    }
    
    // Load programs from @AppStorage
    private func loadPrograms() {
        guard !storedProgramsData.isEmpty else { return }
        do {
            let decoder = JSONDecoder()
            programs = try decoder.decode([Program].self, from: storedProgramsData)
        } catch {
            print("Failed to load programs: \(error)")
        }
    }
    
    // Save programs to @AppStorage
    private func savePrograms() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(programs)
            storedProgramsData = data
        } catch {
            print("Failed to save programs: \(error)")
        }
    }
}

struct ProgramView2: View {
    @Binding var program: Program // Binding to allow modification of the program's state
    var onDelete: () -> Void // Callback for deleting a program
    
    @State private var showingTimePicker: Bool = false
    @State private var editingPeriod: ComfortPeriod? // Track which period is being edited
    @State private var currentStartTime: Date = Date()
    @State private var currentEndTime: Date = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(program.title)
                    .font(.headline)
                
                Spacer()
                
                // Trash icon for deleting the program
                Button(action: {
                    onDelete()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            // Days of the Week Selection
            HStack {
                ForEach(["MO", "TU", "WE", "TH", "FR", "SA", "SU"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14))
                        .frame(width: 30, height: 30)
                        .background(program.selectedDays.contains(day) ? Color.purple : Color.purple.opacity(0.2))
                        .cornerRadius(5)
                        .onTapGesture {
                            toggleDaySelection(day: day)
                        }
                }
            }
            
            // Schedule Bar
            createScheduleBar(comfortPeriods: program.comfortPeriods)
                .padding(.vertical, 5)
            
            // Comfort Periods
            ForEach(program.comfortPeriods.indices, id: \.self) { index in
                HStack {
                    Image(systemName: "clock")
                    
                    // Display time period with edit functionality
                    Button(action: {
                        self.editingPeriod = program.comfortPeriods[index]
                        self.currentStartTime = program.comfortPeriods[index].start
                        self.currentEndTime = program.comfortPeriods[index].end
                        self.showingTimePicker = true
                    }) {
                        Text("\(formatTime(program.comfortPeriods[index].start))–\(formatTime(program.comfortPeriods[index].end))")
                    }
                    .foregroundColor(.black)
                    
                    Spacer()
                    Text(calculateDuration(program.comfortPeriods[index]))
                        .foregroundColor(.orange)
                }
            }
            
            // Add Comfort Period Button
            Button(action: {
                addNewComfortPeriod()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Comfort Period")
                }
                .foregroundColor(.purple)
            }
            
            // Total Duration
            Text("Total Comfort Period duration: \(calculateTotalDuration())")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .sheet(isPresented: $showingTimePicker) {
            TimePickerView(startTime: $currentStartTime, endTime: $currentEndTime, onSave: {
                saveNewTimes()
            })
        }
    }
    
    // Toggle day selection
    private func toggleDaySelection(day: String) {
        if program.selectedDays.contains(day) {
            program.selectedDays.removeAll { $0 == day }
        } else {
            program.selectedDays.append(day)
        }
    }
    
    // Function to add a new comfort period
    private func addNewComfortPeriod() {
        // Add a new default comfort period (e.g., 14:00-16:00)
        let newComfortPeriod = ComfortPeriod(
            start: Calendar.current.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!,
            end: Calendar.current.date(bySettingHour: 16, minute: 0, second: 0, of: Date())!
        )
        program.comfortPeriods.append(newComfortPeriod)
    }
    
    // Calculate total duration for the program
    private func calculateTotalDuration() -> String {
        var totalMinutes = 0
        
        for period in program.comfortPeriods {
            let interval = period.end.timeIntervalSince(period.start)
            totalMinutes += Int(interval) / 60
        }
        
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        return "\(hours)hr \(minutes)min"
    }
    
    // Save new times for the selected comfort period
    private func saveNewTimes() {
        if let periodIndex = program.comfortPeriods.firstIndex(where: { $0 == editingPeriod }) {
            program.comfortPeriods[periodIndex].start = currentStartTime
            program.comfortPeriods[periodIndex].end = currentEndTime
        }
        showingTimePicker = false
    }
    
    // Function to format Date to "HH:mm" for display
    private func formatTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    // Function to calculate duration between start and end times
    private func calculateDuration(_ period: ComfortPeriod) -> String {
        let interval = period.end.timeIntervalSince(period.start)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)hr \(minutes)min"
    }
    
    // Function to generate a horizontal schedule bar
    private func createScheduleBar(comfortPeriods: [ComfortPeriod]) -> some View {
        HStack(spacing: 1) {
            ForEach(0..<24) { hour in
                Rectangle()
                    .fill(self.colorForHour(hour: hour, comfortPeriods: comfortPeriods))
                    .frame(width: 10, height: 10)
            }
        }
        .cornerRadius(5)
    }
    
    // Function to determine color based on time and comfort periods
    private func colorForHour(hour: Int, comfortPeriods: [ComfortPeriod]) -> Color {
        let calendar = Calendar.current
        let hourStart = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        let hourEnd = calendar.date(bySettingHour: (hour + 1) % 24, minute: 0, second: 0, of: Date())!
        
        // Check if any part of the current hour overlaps with any comfort period
        for period in comfortPeriods {
            if period.start < hourEnd && period.end > hourStart {
                return Color.orange // Active comfort period
            }
        }
        
        return Color.blue // Inactive period
    }
}

// Struct to represent a Program
struct Program2: Hashable, Codable {
    var title: String
    var comfortPeriods: [ComfortPeriod]
    var selectedDays: [String] // Store the selected days
    var totalDuration: String
}

// Struct to represent a Comfort Period
struct ComfortPeriod2: Hashable, Codable {
    var start: Date
    var end: Date
}

// Custom Time Picker View
struct TimePickerView2: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
    var onSave: () -> Void
    
    var body: some View {
        VStack {
            DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
            DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
            Button("Save") {
                onSave()
            }
            .padding()
        }
        .padding()
    }
}

// Preview for testing in SwiftUI
struct ScheduleDetailsView_Previews2: PreviewProvider {
    static var previews: some View {
        ScheduleDetailsView()
    }
}

// Preview
struct SettingsView_Previews2: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

// UIKit ViewController to host SwiftUI content
class ViewControllerNoAI2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let noAiThermoView = UIHostingController(rootView: ThermostatView(navigateHome: { [weak self] in
            self?.navigateBackToHome() // Call navigateBackToHome when the back button is pressed
        }))
        addChild(noAiThermoView)
        noAiThermoView.view.frame = view.bounds
        view.addSubview(noAiThermoView.view)
        noAiThermoView.didMove(toParent: self)
    }
    
    // Function to navigate back to Home
    func navigateBackToHome() {
        // If presented modally, dismiss it
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            // If it's part of a navigation controller, pop the current view controller
            self.navigationController?.popViewController(animated: true)
        }
    }
}
