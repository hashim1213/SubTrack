//
//  ServiceMenuView.swift
//  SubTrack
//
//  Created by Hashim Farooq on 2024-03-02.
//

import Foundation
import CoreData
import SwiftUI
import UIKit

// Predefined subscriptions
let predefinedSubscriptions: [(name: String, logoName: String, color: Color)] = [
    (name: "Netflix", logoName: "netflix", color: Color.red),
    (name: "Spotify Premium", logoName: "spotify", color: Color.green),
    (name: "Amazon Prime", logoName: "prime", color: Color.blue),
    (name: "iCloud", logoName: "icloud", color: Color.gray),
    (name: "Apple", logoName: "apple", color: Color.black),
    (name: "Hulu", logoName: "hulu", color: Color.green),
    (name: "HBO", logoName: "hbo", color: Color.blue),
    (name: "Snapchat", logoName: "snapchat", color: Color.yellow),
    (name: "NBA", logoName: "nba", color: Color.blue),
    (name: "Apple Music", logoName: "applemusic", color: Color.red),
    (name: "Youtube", logoName: "youtube", color: Color.red)
    // Add more predefined subscriptions as needed
]


struct ServiceMenuView: View {
    let predefinedSubscriptions: [(name: String, logoName: String, color: Color)]
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @State private var showingAddSubscriptionView = false
    @State private var selectedSubscription: (name: String, logoName: String, color: Color)?
    var body: some View {
        NavigationView {
            VStack{
                ScrollView {
                    Section() {
                        ForEach(predefinedSubscriptions.indices, id: \.self) { index in
                        if predefinedSubscriptions[index].name == "Custom" {
                        NavigationLink(destination: AddSubscriptionView()) {
                            Text("Create custom subscription")
                            }
                        } else {
                        NavigationLink(destination: AddSubscriptionView(subscriptionData: predefinedSubscriptions[index]).navigationBarBackButtonHidden(true)) {
                        HStack {
                        Image(predefinedSubscriptions[index].logoName) // Replace with actual logos
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .cornerRadius(8)
                                                      
                        Text(predefinedSubscriptions[index].name)
                                .foregroundColor(.primary)
                        Spacer()
                                                      
                        Image(systemName: "plus")
                               .foregroundColor(predefinedSubscriptions[index].color)
                }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10) // Set the rounded rectangle shape
            .stroke(predefinedSubscriptions[index].color, lineWidth: 2) // Use stroke for border
            .background(Color.clear) // Set the background to clear
            )

        }
.padding(.horizontal)
    }
}
}
        
                }
                NavigationLink(destination: AddSubscriptionView().navigationBarBackButtonHidden(true)) {
                Text("Create custom subscription")
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.8))) // Darken the color by reducing opacity
                .padding(.horizontal)
                }
            }
            .navigationBarTitle("Add Subscription", displayMode: .inline)
            .navigationBarItems(trailing: EditButton())
            
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .sheet(isPresented: $showingAddSubscriptionView) {
                if let selected = selectedSubscription {
                    AddSubscriptionView(subscriptionData: selected)
                } else {
                    AddSubscriptionView() // For custom subscription
                }
            }
        }
    }
}


