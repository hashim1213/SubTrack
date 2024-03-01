//
//  addSubscriptions.swift
//  SubTrack
//
//  Created by Hashim Farooq on 2024-02-29.
//

import Foundation
import SwiftUI
import UIKit
import CoreData

// Predefined subscriptions
let predefinedSubscriptions: [(name: String, iconName: String, color: Color)] = [
    (name: "Custom", iconName: "custom", color: Color.gray),
    (name: "Netflix", iconName: "netflix", color: Color.red),
    (name: "Spotify Premium", iconName: "spotify", color: Color.green),
    (name: "Amazon Prime", iconName: "prime", color: Color.blue),
    (name: "iCloud", iconName: "icloud", color: Color.gray)
    // Add more predefined subscriptions as needed
]




struct AddSubscriptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @State private var name: String = ""
    @State private var cost: String = ""
    @State private var billingCycle: String = ""
    @State private var category: String = "Entertainment"
    @State private var billingDate = Date()
    @State private var selectedPredefinedIndex = 0  // For predefined subscriptions
    @State private var icon: String = ""
    @State private var backgroundColor: Color = Color.gray
    @State private var selectedBillingCycleIndex = 0
    @State private var selectedCategoryIndex = 0
     @State private var selectedCurrencyIndex = 0
     @State private var showingServiceMenu = false
     @State private var selectedSubscriptionIndex: Int? = nil
    
    let currencies = ["USD", "EUR", "GBP", "JPY"]
    let billingCycles = ["Monthly", "Annual", "Bi-Weekly", "Weekly"]
    let categories = ["Entertainment", "Utilities", "Health", "Education"]
    
    var body: some View {
        NavigationView {
              Form {
                  Button("Choose Subscription") {
                      showingServiceMenu = true
                  }
                  
                  if let index = selectedSubscriptionIndex {
                      Text("Selected: \(predefinedSubscriptions[index].name)")
                  }

                  
                  CustomTextField(label: "Name", text: $name)
                  
                  CustomTextField(label: "Cost", text: $cost)
                      .keyboardType(.decimalPad)
                
                ColorPicker("Color", selection: $backgroundColor) // Empty string for inline label
                //.labelsHidden() // Hides the inline label
                                
                  Picker("Currency", selection: $selectedCurrencyIndex) {
                      ForEach(0..<currencies.count, id: \.self) {
                          Text(self.currencies[$0])
                      }
                  }
                  
                  DatePicker("Billing Date", selection: $billingDate, displayedComponents: .date)
                  
                  Picker("Billing Cycle", selection: $selectedBillingCycleIndex) {
                      ForEach(0..<billingCycles.count, id: \.self) {
                          Text(self.billingCycles[$0])
                      }
                  }
                  
                  Picker("Category", selection: $selectedCategoryIndex) {
                      ForEach(0..<categories.count, id: \.self) {
                          Text(self.categories[$0])
                      }
                  }
                  
                  Button(action: saveSubscription) {
                      Text("Save")
                          .foregroundColor(.white)
                          .frame(maxWidth: .infinity)
                          .padding()
                          .background(Color.green)
                          .cornerRadius(10)
                  }
              }
              .navigationBarTitle("Add a subscription", displayMode: .inline)
              .navigationBarItems(leading: Button("Cancel", action: {
                  presentationMode.wrappedValue.dismiss()
              }))
              .sheet(isPresented: $showingServiceMenu) {
                  ServiceMenuView(predefinedSubscriptions: predefinedSubscriptions, selectedSubscriptionIndex: $selectedSubscriptionIndex)
              }
          }
      }
    func saveSubscription() {
        let newSubscription = SubscriptionEntity(context: viewContext)
        newSubscription.id = UUID()
        newSubscription.name = name
        newSubscription.price = NSDecimalNumber(string: cost)
        newSubscription.billingDate = billingDate
        newSubscription.logoName = icon
        newSubscription.backgroundColor = UIColor(backgroundColor).toHexString()
        newSubscription.billingCycle = billingCycles[selectedBillingCycleIndex]
        newSubscription.category = categories[selectedCategoryIndex]
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            viewContext.rollback()
            print("Failed to save subscription: \(error.localizedDescription)")
        }
    }
    func colorToString(_ color: Color) -> String {
        let uiColor = UIColor(color)
        return uiColor.toHexString()
    }

    
}

extension Color {
    func toUIColor() -> UIColor {
        if #available(iOS 14.0, *) {
            return UIColor(self)
        } else {
            // Fallback for earlier iOS versions
            let components = self.components()
            return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
        }
    }
    
    // Decompose Color to its RGBA components
    private func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}

struct CustomTextField: View {
    var label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if isSecure {
                SecureField("", text: $text)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
            } else {
                TextField("", text: $text)
                    .keyboardType(keyboardType)
                    .padding(10)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
            }
        }
        .padding(.horizontal)
    }
}
struct ServiceMenuView: View {
    var predefinedSubscriptions: [(name: String, iconName: String, color: Color)]
    @Binding var selectedSubscriptionIndex: Int?
    @State private var searchText = ""

    var filteredSubscriptions: [(name: String, iconName: String, color: Color)] {
        if searchText.isEmpty {
            return predefinedSubscriptions
        } else {
            return predefinedSubscriptions.filter { $0.name.contains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredSubscriptions.indices, id: \.self) { index in
                    Button(action: {
                        self.selectedSubscriptionIndex = index
                    }) {
                        HStack {
                            Image(systemName: filteredSubscriptions[index].iconName) // Assuming system icons for simplicity
                                .foregroundColor(filteredSubscriptions[index].color)
                            Text(filteredSubscriptions[index].name)
                        }
                    }
                }
            }
            .navigationTitle("Select a Service")
            .searchable(text: $searchText)
        }
    }
}

