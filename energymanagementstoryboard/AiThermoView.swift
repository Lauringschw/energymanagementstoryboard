import SwiftUI
import Charts
import CoreML
import Foundation



struct AiThermoView: View {
    var navigateHome: () -> Void // Added callback for navigation

    @State private var mode: String = "Auto"
    @State private var workingStatus: String = "Heating..."
    @State private var selectedFeeling: String = "A Little Hot"
    
    // Core ML Model
    @State private var thermostatModel: ThermostatModel? = nil
    @State private var modelLoadError: Error? = nil
    
    @State private var predictedTemperature: Double = 20.0
    
    // State for dragging the circle in Manual mode
    @State private var manualTemperature: CGFloat = 10.0
    @State private var isManualMode: Bool = false
    @State private var circleOffset: CGSize = CGSize.zero
    @State private var circleAngle: CGFloat = -90
    
    // Prediction Input Variables
    
    @State private var locationStatus: Int64 = 0
    @State private var preferredTemperature: Double = 22
    @State private var currentTemperature: Double = 10.3
    @State private var userFeedback: Int64 = 2
    @State private var energySavingMode: Int64 = 0
    @State private var manualOverrideStatus: Int64 = 0
    @State private var temperatureAdjustment: Double = 0.5
    @State private var outsideTemperature: Double = 10
    
    // Sample data for the large temperature graph
    @State private var temperatureData: [TemperatureData] = [
        TemperatureData(time: "6 AM", temperature: 15.0),
        TemperatureData(time: "9 AM", temperature: 20.0),
        TemperatureData(time: "12 PM", temperature: 22.5),
        TemperatureData(time: "3 PM", temperature: 24.0),
        TemperatureData(time: "6 PM", temperature: 23.0),
        TemperatureData(time: "9 PM", temperature: 21.5),
        TemperatureData(time: "12 AM", temperature: 18.0),
        TemperatureData(time: "3 AM", temperature: 15.5),
    ]
    
    // Prediction data (small chart) with split time for spanning across days
    @State private var temperaturePredictionData: [TemperaturePredictionData] = [
        TemperaturePredictionData(timeStart: 0, timeEnd: 6, temperature: 16.0),
        TemperaturePredictionData(timeStart: 6, timeEnd: 9, temperature: 22.0),
        TemperaturePredictionData(timeStart: 9, timeEnd: 16, temperature: 16.0),
        TemperaturePredictionData(timeStart: 16, timeEnd: 21, temperature: 22.0),
        TemperaturePredictionData(timeStart: 21, timeEnd: 24, temperature: 16.0)
    ]
    
    // Sample temperature data structure
    struct TemperatureData: Identifiable {
        var id = UUID()
        var time: String
        var temperature: Double
    }
    
    // Sample temperature prediction data structure
    struct TemperaturePredictionData: Identifiable {
        var id = UUID()
        var timeStart: Double
        var timeEnd: Double
        var temperature: Double
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Title and navigation back button
                    HStack {
                        Button(action: {
                            navigateHome() // Trigger the navigation callback
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24))
                                .padding(.leading, 20)
                        }
                        Text("KITCHEN")
                            .font(.headline)
                            .padding(.leading, 10)
                        Spacer()
                    }
                    .padding(.top, 0)
                    
                    Spacer().frame(height: 30)
                    
                    // Current temperature label
                    HStack {
                        Text("Current Temperature")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.leading, 20)
                        Spacer()
                    }
                    
                    Spacer().frame(height: 0)
                    
                    // Feedback button and circular temperature indicator
                    HStack(alignment: .center) {
                        Menu {
                            Button("Too Warm") {
                                updateFeelingSelection(feeling: "Too Warm")
                            }
                            Button("A Little Warm") {
                                updateFeelingSelection(feeling: "A Little Warm")
                            }
                            Button("Perfect") {
                                updateFeelingSelection(feeling: "Perfect")
                            }
                            Button("A Little Cold") {
                                updateFeelingSelection(feeling: "A Little Cold")
                            }
                            Button("Too Cold") {
                                updateFeelingSelection(feeling: "Too Cold")
                            }
                        } label: {
                            Text(selectedFeeling)
                                .frame(width: 100, height: 100)
                                .background(getFeelingBackgroundColor())
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .font(.system(size: 16))
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        
                        ZStack {
                            Circle()
                                .trim(from: 0, to: 0.75)
                                .stroke(Color.green, lineWidth: 30)
                                .frame(width: 180, height: 180)
                                .rotationEffect(.degrees(-90))
                            
                            Text(String(format: "%.1f°", currentTemperature))
                                .font(.system(size: 64))
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            if isManualMode {
                                GeometryReader { geometry in
                                    Circle()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                        .overlay(Text(String(format: "%.1f", manualTemperature)).foregroundColor(.white))
                                        .position(positionForCircle(in: geometry.size))
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                                    var angle = atan2(value.location.y - center.y, value.location.x - center.x)
                                                    
                                                    let angleInDegrees = angle * 180 / .pi
                                                    
                                                    if angleInDegrees < -90 && angleInDegrees > -180 {
                                                        print("Angle restricted, outside of allowable range.")
                                                    } else {
                                                        updateManualTemperature(angle: angle)
                                                    }
                                                }
                                        )
                                }
                                .frame(width: 180, height: 180)
                            }
                        }
                        .padding(.trailing, 20)
                    }
                    
                    Spacer().frame(height: 40)
                    
                    // First (Large) graph for temperature readings (line chart)
                    Chart(temperatureData) { data in
                        AreaMark(
                            x: .value("Time", data.time),
                            yStart: .value("Temperature", data.temperature),
                            yEnd: .value("Baseline", 0)
                        )
                        .foregroundStyle(Gradient(colors: [Color.gray.opacity(0.3), Color.clear]))
                        
                        LineMark(
                            x: .value("Time", data.time),
                            y: .value("Temperature", data.temperature)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(Color.blue)
                        
                        PointMark(
                            x: .value("Time", data.time),
                            y: .value("Temperature", data.temperature)
                        )
                        .foregroundStyle(Color.blue)
                    }
                    .frame(height: 150)
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 40)
                    
                    // Schedule logo and text above the new small chart
                    HStack(spacing: 5) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 24))
                        Text("Schedule")
                            .font(.system(size: 16))
                        Spacer()
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Small horizontal bar chart (Heating and Cooling) based on prediction data
                    VStack {
                        ZStack {
                            HStack(spacing: 0) {
                                ForEach(temperaturePredictionData) { prediction in
                                    Rectangle()
                                        .fill(prediction.temperature == 16 ? Color.blue : Color.orange)
                                        .frame(width: CGFloat(prediction.timeEnd - prediction.timeStart) * 15)
                                }
                            }
                            .frame(height: 30)
                        }
                        
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("6")
                            Spacer()
                            Image(systemName: "sun.max.fill")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("18")
                            Spacer()
                            Image(systemName: "moon.fill")
                                .foregroundColor(.gray)
                        }
                        .font(.system(size: 12))
                        .padding(.horizontal, 10)
                    }
                    
                    Spacer().frame(height: 40)
                    
                    // Mode and Working Status at the very bottom
                    HStack {
                        VStack {
                            Text("Mode")
                                .foregroundColor(.gray)
                            Menu {
                                Button("Auto") {
                                    mode = "Auto"
                                    isManualMode = false
                                    predictTemperature()
                                }
                                Button("Manual") {
                                    mode = "Manual"
                                    isManualMode = true
                                }
                                Button("Off") {
                                    mode = "Off"
                                    isManualMode = false
                                }
                            } label: {
                                Text(mode)
                                    .frame(width: 150, height: 30)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.black)
                                    .cornerRadius(5)
                                    .padding(.top, 5)
                            }
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("Working Status")
                                .foregroundColor(.gray)
                            HStack {
                                if workingStatus.contains("Heating") {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                } else if workingStatus.contains("Cooling") {
                                    Image(systemName: "snowflake")
                                        .foregroundColor(.blue)
                                }
                                Text(workingStatus)
                                    .font(.headline)
                            }
                        }
                        .onAppear{
                            loadAiThermoSettings()
                        }
                    }
                    .padding(.horizontal, 40)
                    .onDisappear(){
                        saveAiThermoSettings()
                    }
                }
                .padding(.horizontal, 20)
                
                if mode == "Off" {
                    Color.black.opacity(0.6)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }
        .onAppear {
            loadThermostatModel()
        }
    }
    
    // Function to load the Core ML model with error handling
    private func loadThermostatModel() {
        do {
            let config = MLModelConfiguration()
            thermostatModel = try ThermostatModel(configuration: config)
            print("Model loaded successfully!")
        } catch {
            modelLoadError = error
            print("Error loading the model: \(error)")
        }
    }
    
    // Prediction function
    private func predictTemperature() {
        guard let thermostatModel = thermostatModel else {
            print("Model not loaded, skipping prediction")
            return
        }
        
        let timestamp = String(Date().timeIntervalSince1970)
        let input = ThermostatModelInput(
            Timestamp: timestamp,
            Location_status: locationStatus,
            Preferred_temperature: preferredTemperature,
            Current_temperature: currentTemperature,
            User_feedback: userFeedback,
            Energy_saving_mode: energySavingMode,
            Manual_override_status: manualOverrideStatus,
            Temperature_adjustment: temperatureAdjustment,
            Outside_temperature: outsideTemperature
        )
        
        print("Input values: \(input)")
        
        do {
            let prediction = try thermostatModel.prediction(input: input)
            print("Prediction successful!")
            print("Available output features: \(prediction.featureNames)") // Print available features
            
            // Apply the NumberFormatter for correct locale (force dot decimal)
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = Locale(identifier: "en_US_POSIX") // Use US locale to enforce dot decimal
            numberFormatter.numberStyle = .decimal
            
            // Ensure Target_temperature exists and is correctly formatted
            if let targetTemperatureFeature = prediction.featureValue(for: "Target_temperature")?.doubleValue {
                // Format the target temperature using the locale formatter
                if let formattedTemperature = numberFormatter.string(from: NSNumber(value: targetTemperatureFeature)) {
                    print("Formatted Target Temperature: \(formattedTemperature)")
                }
                predictedTemperature = targetTemperatureFeature
                // Update the chart with the predicted value
                temperatureData = updateTemperatureData(with: predictedTemperature)
            } else {
                print("Target_temperature not found in the prediction output")
            }
        } catch let error as NSError {
            print("FAT ERROR IN predictTemperature" + String(describing: error))
            print("Error making prediction: \(error), \(error.userInfo)")
        }
    }
    
    private func updateTemperatureData(with predictedTemperature: Double) -> [TemperatureData] {
        var updatedData = temperatureData
        if let lastData = updatedData.last {
            updatedData.append(TemperatureData(time: "Next", temperature: predictedTemperature))
        }
        return updatedData
    }
    
    private func loadAiThermoSettings() {
        if let settings = FileUtility.shared.readSettings(fileName: "ai_thermo_settings.txt") {
            if let savedMode = settings["Mode"] {
                mode = savedMode
            }
            if let savedManualTemp = settings["Manual Temperature"],
               let manualTemp = Double(savedManualTemp) {
                manualTemperature = CGFloat(manualTemp)
            }
            if let savedFeeling = settings["Selected Feeling"] {
                selectedFeeling = savedFeeling
            }
        }
    }
    
    private func saveAiThermoSettings() {
        let settings = """
        Mode: \(mode)
        Manual Temperature: \(manualTemperature)
        Selected Feeling: \(selectedFeeling)
        Changed At: \(Date())
        """
        FileUtility.shared.writeToFile(fileName: "ai_thermo_settings.txt", content: settings + "\n")
    }
    
    // Update the feeling selection and button appearance based on the selection
    private func updateFeelingSelection(feeling: String) {
        selectedFeeling = feeling
        
        let logEntry = """
        Feeling: \(feeling)
        Current Temperature: \(currentTemperature)
        Time: \(Date())
        Outside Temperature: \(getOutsideTemperature())
        """
        FileUtility.shared.writeToFile(fileName: "user_input_log.txt", content: logEntry + "\n")
        
        switch feeling {
        case "Too Warm":
            print("Selected feeling: Too Warm")
        case "A Little Warm":
            print("Selected feeling: A Little Warm")
        case "Perfect":
            print("Selected feeling: Perfect")
        case "A Little Cold":
            print("Selected feeling: A Little Cold")
        case "Too Cold":
            print("Selected feeling: Too Cold")
        default:
            print("Selected feeling: Default")
        }
    }
    
    // Set the background color of the feedback button based on the selection
    private func getFeelingBackgroundColor() -> Color {
        switch selectedFeeling {
        case "Too Warm":
            return Color.red
        case "A Little Warm":
            return Color.orange.opacity(0.8)
        case "Perfect":
            return Color.green
        case "A Little Cold":
            return Color.blue.opacity(0.5)
        case "Too Cold":
            return Color.blue
        default:
            return Color.orange
        }
    }
    
    // Calculate the position of the draggable circle along the ring
    private func positionForCircle(in size: CGSize) -> CGPoint {
        let radius = size.width / 2
        let angle = Angle.degrees(Double(circleAngle))
        let x = radius + radius * CGFloat(cos(angle.radians))
        let y = radius + radius * CGFloat(sin(angle.radians))
        return CGPoint(x: x, y: y)
    }
    
    // Update the manual temperature based on the dragging angle
    private func updateManualTemperature(angle: CGFloat) {
        // Calculate degrees from the angle and map it between 10 and 40
        let normalizedAngle = (angle + .pi / 2) / (.pi * 2)
        var temp = normalizedAngle * 35 + 10 // Map to 10-40 range
        
        // Round to the nearest 0.5
        temp = round(temp * 2) / 2
        
        // Update the manual temperature
        manualTemperature = max(10, min(45, temp))
        
        // Update the draggable circle's angle
        circleAngle = angle * 180 / .pi
        
        // Update the working status based on temperature comparison
        if manualTemperature > CGFloat(currentTemperature) {
            workingStatus = "Heating..."
        } else if manualTemperature < CGFloat(currentTemperature) {
            workingStatus = "Cooling..."
        } else {
            workingStatus = "Steady..."
        }
    }
    
    // Mock function to get outside temperature
    private func getOutsideTemperature() -> Double {
        // Replace with actual implementation to get outside temperature
        return 15.0
    }
    
    
}

import SwiftUI

struct SettingsView: View {
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
                    .padding(.bottom, 30) // Adds extra space before Location Control section
                    
                    // Location Control Section
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.system(size: 24))
                        Text("Location Control")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: $locationControlEnabled)
                            .labelsHidden()
                            .onChange(of: locationControlEnabled) { newValue in
                                saveSettings()
                            }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20) // Adds extra space between Schedule and Location Control
                    
                    Text("AI monitors your location, lowering the temperature when you leave and raising it when you return. It adapts to your routine, ensuring comfort and energy efficiency automatically.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
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
                    
                    // Energy-Saving Mode Section
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 24))
                        Text("Energy-Saving Mode")
                            .font(.headline)
                        Spacer()
                        Toggle("", isOn: $energySavingModeEnabled)
                            .labelsHidden()
                            .onChange(of: energySavingModeEnabled) { newValue in
                                saveSettings()
                            }
                    }
                    .padding(.horizontal)
                    
                    Text("Enable energy-saving mode to let AI reduce energy consumption during peak hours or when you're away. The system balances comfort with efficiency, helping you save on energy bills.")
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


struct ScheduleDetailsView: View {
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

struct ProgramView: View {
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
struct Program: Hashable, Codable {
    var title: String
    var comfortPeriods: [ComfortPeriod]
    var selectedDays: [String] // Store the selected days
    var totalDuration: String
}

// Struct to represent a Comfort Period
struct ComfortPeriod: Hashable, Codable {
    var start: Date
    var end: Date
}

// Custom Time Picker View
struct TimePickerView: View {
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
struct ScheduleDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleDetailsView()
    }
}

// Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

// UIKit ViewController to host SwiftUI content
class ViewControllerAI: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let aiThermoView = UIHostingController(rootView: AiThermoView(navigateHome: { [weak self] in
            self?.navigateBackToHome() // Call navigateBackToHome when the back button is pressed
        }))
        addChild(aiThermoView)
        aiThermoView.view.frame = view.bounds
        view.addSubview(aiThermoView.view)
        aiThermoView.didMove(toParent: self)
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
