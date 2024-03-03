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



struct AddSubscriptionView: View {
    var subscriptionData: (name: String, logoName: String, color: Color)?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    @State private var name: String = ""
    @State private var descriptionText: String = ""
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
    @State private var iconImage: Image? = nil
    @State private var showingIconSelectionSheet = false
     //@State private var selectedSubscriptionIndex: Int? = nil
   
    init(subscriptionData: (name: String, logoName: String, color: Color)? = nil) {
            self.subscriptionData = subscriptionData
            _name = State(initialValue: subscriptionData?.name ?? "")
            _cost = State(initialValue: "") // Add logic if you have cost data
            _backgroundColor = State(initialValue: subscriptionData?.color ?? .gray)
            _icon = State(initialValue: subscriptionData?.logoName ?? "")
            // Initialize other properties if needed
        }

    
    let currencies = ["CAD $","USD $", "EUR", "GBP", "JPY"]
    let billingCycles = ["Monthly", "Annual", "Bi-Weekly", "Weekly"]
    let categories = ["Entertainment", "Utilities", "Health", "Education"]
    
    var body: some View {
        NavigationView {
            VStack{
                Spacer()
                HStack {
                    if let logoName = subscriptionData?.logoName, !logoName.isEmpty {
                    Image(logoName) // Assuming you have an image with this name in your assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                        //.background(Circle().fill(subscriptionData?.color ?? Color.gray))
                    } else {
                        Button(action: {
                            if iconImage == nil {
                                // If there is no icon, show the sheet to select one
                                showingIconSelectionSheet = true
                            } else {
                                // If there is an icon, you could perform another action
                            }
                        }) {
                            if let iconImage = iconImage {
                                iconImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75, height: 75)
                                    .background(Circle().fill(backgroundColor))
                            } else {
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 75, height: 75)
                                    .background(Circle().fill(Color.gray))
                            }
                        }
                        
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $showingIconSelectionSheet) {
                            // Your view for icon selection goes here
                            IconSelectionView(selectedIcon: $iconImage)
                        }
                    }
                      
                    
                    Picker("Currency", selection: $selectedCurrencyIndex) {
                        ForEach(0..<currencies.count, id: \.self) {
                            Text(self.currencies[$0])
                        }
                    }
                    .padding(6)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
                    
                    .pickerStyle(MenuPickerStyle())
                    .labelsHidden()
                    
                    TextField("0.00", text: $cost)
                        .font(.system(size: 20)) // Adjust the size as needed
                        .bold()
                        .padding(10)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary, lineWidth: 1))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        
                    
                }.padding(.horizontal)
                    .padding(.top)
                Form {
                    
                    TextField("Name", text: $name)
                    TextField("Description", text: $descriptionText)
                    ColorPicker("Color", selection: $backgroundColor) // Empty string for inline label
                    //.labelsHidden() // Hides the inline label
                    
                    DatePicker("First Bill", selection: $billingDate, displayedComponents: .date)
                    
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
                    /*
                     Button(action: saveSubscription) {
                     Text("Save")
                     .foregroundColor(.white)
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color.green)
                     .cornerRadius(10)
                     }
                     */
                }
            }
            .navigationBarTitle("New subscription", displayMode: .inline)
            .navigationBarBackButtonHidden(true) // Hide the default back button
            .navigationBarItems(leading: backButton, trailing: addButton)
              
          }
        .background(backgroundColor)
      }
   
        var addButton: some View {
              Button(action: saveSubscription) {
                  Image(systemName: "plus")
              }
          }

          var backButton: some View {
              Button(action: {
                  presentationMode.wrappedValue.dismiss()
              }) {
                  HStack {
                      Image(systemName: "arrow.left") // Use the appropriate system image
                      Text("") // Empty Text view for no title next to the back arrow
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

struct IconSelectionView: View {
    @Binding var selectedIcon: Image?
    
    // Example icons array, replace with your actual data
    let icons: [String] = ["camera.fill", "star.fill", "heart.fill"]
    
    var body: some View {
        // Layout for icon selection, just an example
        List {
            ForEach(icons, id: \.self) { iconName in
                Button(action: {
                    // Set the selected icon and dismiss
                    selectedIcon = Image(systemName: iconName)
                }) {
                    Image(systemName: iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                }
            }
        }
    }
}
