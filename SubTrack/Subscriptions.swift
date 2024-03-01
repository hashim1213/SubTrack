import SwiftUI
import CoreData
import UIKit

struct SubscriptionsListView: View {
    @State private var showingAddSubscriptionSheet = false
     @State private var showingDetailsSheet = false
     @State private var selectedSubscription: SubscriptionEntity?
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: SubscriptionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionEntity.name, ascending: true)]
    ) var subscriptions: FetchedResults<SubscriptionEntity>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(subscriptions) { subscription in
                        SubscriptionItemView(subscription: subscription)
                            .onTapGesture {
                                self.selectedSubscription = subscription
                                self.showingDetailsSheet = true
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Subscriptions")
            .navigationBarItems(trailing: addButton)
            .sheet(isPresented: $showingAddSubscriptionSheet) {
                AddSubscriptionView().environment(\.managedObjectContext, self.viewContext)
            }
            .sheet(isPresented: $showingDetailsSheet) {
                if let subscription = selectedSubscription {
                    SubscriptionDetailView(subscription: subscription)
                }
            }
        }
    }

    var addButton: some View {
        Button(action: {
            showingAddSubscriptionSheet = true
        }) {
            Image(systemName: "plus")
        }
    }
}

struct SubscriptionItemView: View {
    let subscription: SubscriptionEntity

    var body: some View {
        HStack {
            // Placeholder for Image, replace with actual logo images from your assets
            Image(subscription.logoName ?? "defaultLogo") // Use a placeholder icon if `logoName` is nil
                          .resizable()
                          .scaledToFit()
                          .frame(width: 40, height: 40)
                          .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(subscription.name ?? "Unknown")
                    .font(.headline)
                Text(numberFormatter.string(from: subscription.price ?? NSDecimalNumber(value: 0)) ?? "$0.00")
                    .font(.subheadline)
            
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(subscription.billingCycle ?? "Unknown")
                    .font(.footnote)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20)
            .fill(subscriptionColor) )// Use dynamic color) // Placeholder for dynamic color
        .shadow(radius: 5)
    }
    var numberFormatter: NumberFormatter {
          let formatter = NumberFormatter()
          formatter.numberStyle = .currency
          // Configure the formatter as needed
          return formatter
      }
    // Computed property to dynamically create a Color from subscription.backgroundColor
    var subscriptionColor: Color {
        if let hexColor = subscription.backgroundColor, let uiColor = UIColor(hex: hexColor) {
            return Color(uiColor: uiColor)
        }
        return Color.gray // Default color if conversion fails
    }

}

extension UIColor {
    convenience init?(hex: String) {
         var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
         hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

         var rgb: UInt64 = 0

         Scanner(string: hexSanitized).scanHexInt64(&rgb)

         let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
         let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
         let blue = CGFloat(rgb & 0x0000FF) / 255.0

         self.init(red: red, green: green, blue: blue, alpha: 1.0)
     }
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
}
