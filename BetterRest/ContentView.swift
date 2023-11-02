//
//  ContentView.swift
//  BetterRest
//
//  Created by Dillon Teakell on 10/25/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    // Core Data Properties
    static var defaultWakeupTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    @State var wakeUpTime = defaultWakeupTime
    @State private var hoursOfSleep = 6.0
    @State private var cupsOfCoffee = 1
    
    // Calculation Properties
    var calculatedSleepTime: String {
        do {
            // Configure and setup ML Model
            let model = try SleepCalculator(configuration: MLModelConfiguration())
            
            // Get date components
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            // Get prediction data
            let prediction = try model.prediction(wake: Int64(hour + minute), estimatedSleep: hoursOfSleep, coffee: Int64(cupsOfCoffee))
            let sleepTime = wakeUpTime - prediction.actualSleep
            
            // Alert Message
            return "\(sleepTime.formatted(date: .omitted, time: .shortened))"
            
        } catch {
            return "Error"
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Wake up Time Section
                WakeupSection(wakeUpTime: $wakeUpTime)
                
                // Amount of Sleep Section
                HoursView(hoursOfSleep: $hoursOfSleep)
                
                // Cups of Coffee Section
                CoffeeView(cupsOfCoffee: $cupsOfCoffee)
                
                // Calculated Sleep View
                CalculatedSleepView(calculatedSleepTime: calculatedSleepTime)
                    
            }
            .navigationTitle("Better Rest")
        }
    }
}

#Preview {
    ContentView()
}

struct WakeupSection: View {
    @Binding var wakeUpTime: Date
    var body: some View {
        Section ("Desired Wake Up Time") {
            DatePicker("Wake Up Time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
        }
    }
}

struct HoursView: View {
    
    @Binding var hoursOfSleep: Double
    var body: some View {
        Section ("Desired Amount of Sleep") {
            Text("\(hoursOfSleep.formatted()) Hours")
            Slider(value: $hoursOfSleep, in: 5...10, step: 0.5)
        
        }
    }
}

struct CoffeeView: View {
    @Binding var cupsOfCoffee: Int
    var body: some View {
        Section ("Daily Coffee Intake") {
            Picker("Cups of Coffee", selection: $cupsOfCoffee){
                ForEach(0...8, id: \.self){number in
                Text("\(number)")}
            }
        }
    }
}

struct CalculatedSleepView: View {
    var calculatedSleepTime: String
    var body: some View {
        Section ("Ideal Bedtime"){
            HStack {
                Image(systemName: "bed.double.fill")
                    .foregroundStyle(.accent)
                Text(calculatedSleepTime)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
