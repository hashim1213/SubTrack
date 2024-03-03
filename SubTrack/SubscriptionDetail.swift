//
//  SubscriptionDetail.swift
//  SubTrack
//
//  Created by Hashim Farooq on 2024-02-29.
//

import Foundation
import SwiftUI
import DeviceActivity
import FamilyControls

struct SubscriptionDetailView: View {
    let subscription: SubscriptionEntity
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

       @State private var showingLogUsageSheet = false
    var body: some View {
        VStack {
            // Assuming you have an image with the same name as the subscription name in your assets
            Image(subscription.logoName ?? "placeholder")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 20)

            Text(subscription.name ?? "Subscription")
                .font(.largeTitle)
                .bold()
                .padding(.top, 10)
            

            Text("Expires in \(daysUntilExpiration(startingFrom: subscription.billingDate, forCycle: subscription.billingCycle)) days")

                .foregroundColor(.gray)
                .padding(.bottom, 20)
            VStack(){
                DetailRow(label: "Month", value: formatMonth(subscription.billingDate))
                
                DetailRow(label: "Amount", value: formatCurrency(subscription.price))
                
                DetailRow(label: "Begins", value: formatDate(subscription.billingDate))
                
                DetailRow(label: "Ends", value: formatDate(calculateEndDate(subscription.billingDate)))
                
                // DetailRow(label: "Type", value: subscription.subscriptionType ?? "Standard")
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            .padding()
            Button("Log Usage") {
                showingLogUsageSheet = true
            }
                        .buttonStyle(GeneralButtonStyle())
            Spacer()
            HStack{
                Button("Delete") {
                    deleteSubscription()
                }
                .foregroundColor(.red)
                .padding()
                .background(Color.clear) // Make the background clear if you only want the border
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red, lineWidth: 2) // Here you can set the border color and line width
                )
                Button("Cancel") {
                    deleteSubscription()
                }.foregroundColor(.white)
                    
                    .padding()
                    .background(Color.mint)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showingLogUsageSheet) {
                      //LogUsageView(subscription: subscription)
                  }
    }
  


    func deleteSubscription() {
        viewContext.delete(subscription)
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
    private func daysUntilExpiration(startingFrom startDate: Date?, forCycle cycle: String?) -> Int {
        guard let startDate = startDate, let cycle = cycle else { return 0 }
        
        let calendar = Calendar.current
        let today = Date()
        
        // Determine the end date based on the billing cycle
        var dateComponents = DateComponents()
        switch cycle {
        case "Monthly":
            dateComponents.month = 1
        case "Annual":
            dateComponents.year = 1
        case "Bi-Weekly":
            dateComponents.day = 14
        case "Weekly":
            dateComponents.weekOfYear = 1
        default:
            break
        }
        
        guard let endDate = calendar.date(byAdding: dateComponents, to: startDate) else { return 0 }
        
        // Calculate the number of days until the end date
        let components = calendar.dateComponents([.day], from: today, to: endDate)
        return components.day ?? 0
    }

    private func formatMonth(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func formatCurrency(_ amount: NSDecimalNumber?) -> String {
        guard let amount = amount else { return "$0.00" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: amount) ?? "$0.00"
    }

    private func calculateEndDate(_ startDate: Date?) -> Date {
        // Assuming monthly subscription for this example
        guard let startDate = startDate else { return Date() }
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: 1, to: startDate) ?? Date()
    }
}

struct LogUsageView: View {

    @State private var usageDescription: String = ""
  
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                TextField("Description", text: $usageDescription)
                Button("Log Usage") {
                    logUsage()
                }
                .buttonStyle(GeneralButtonStyle())
            }
            .navigationBarTitle("Log Usage", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    func logUsage() {
        // Functionality to log usage with a description and timestamp
       // print("Usage logged for \(subscription.name ?? "Unknown"): \(usageDescription)")
        // Here, add logic to save the log to CoreData or your desired storage
        presentationMode.wrappedValue.dismiss()
    }
}

struct GeneralButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
    }
}


struct DetailRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label)
                .bold()
                .frame(width: 80, alignment: .leading)
            Spacer()
            Text(value)
                .frame(alignment: .trailing)
        }
        .padding(.horizontal)
        .padding(.top)
        .padding(.bottom)
    }
}

struct DeleteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct CancelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

// You will need to extend SubscriptionEntity to have computed properties
// for formattedPrice, formattedStartDate, formattedEndDate, subscriptionType, and monthOfSubscription.
// These properties should return the appropriate string representations of the subscription data.
extension DateFormatter {
    static let subscriptionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy" // Customize the date format to your needs
        return formatter
    }()
}
