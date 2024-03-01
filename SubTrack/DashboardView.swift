import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: SubscriptionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionEntity.billingDate, ascending: true)],
        predicate: NSPredicate(format: "billingDate < %@", Date().addingTimeInterval(30 * 24 * 60 * 60) as NSDate)
    ) var endingSubscriptions: FetchedResults<SubscriptionEntity>
    
    @FetchRequest(
        entity: SubscriptionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \SubscriptionEntity.billingDate, ascending: true)]
    ) var subscriptions: FetchedResults<SubscriptionEntity>
    
    func randomGreeting() -> String {
        let greetings = ["Hello", "Hi", "Greetings", "Welcome", "Hey there", "Hola", "Howdy"]
        return greetings.randomElement() ?? "Hello"
    }

    var body: some View {
        NavigationView {
            ScrollView{
                VStack {
                    // Total Spending Card
                    DashboardCardView(title: "Monthly Spending", detail: "$\(calculateTotalSpending())")
                    
                    // Upcoming Bills Card
                   // DashboardCardView(title: "Upcoming Bills", detail: "$\(calculateUpcomingBills())")
                    
                    // Subscriptions Ending Soon Section
                    if !endingSubscriptions.isEmpty {
                                      Text("Subscriptions Ending Soon")
                                          .font(.caption)
                                          .padding()

                                      // Use LazyVGrid to arrange items in grid with 2 columns
                                      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                          ForEach(endingSubscriptions) { subscription in
                                              SubscriptionCardView(subscription: subscription)
                                          }
                                      }
                                      .padding(.horizontal)
                                  }
                    
                  
                }
            }
            .navigationTitle("\(randomGreeting()), Hashim")
        }
    }
  
    
    private func calculateTotalSpending() -> String {
        let totalSpending = subscriptions.reduce(0) { total, subscription in
            total + (subscription.price?.doubleValue ?? 0.0)
        }
        return String(format: "%.2f", totalSpending)
    }


    private func calculateUpcomingBills() -> Double {
        // Filter subscriptions that have their billing date within the next 30 days
        // and sum their prices
        let today = Date()
        let upcomingDate = Calendar.current.date(byAdding: .day, value: 30, to: today)!
        
        return subscriptions
            .filter { subscription in
                if let billingDate = subscription.billingDate {
                    return billingDate >= today && billingDate <= upcomingDate
                }
                return false
            }
            .reduce(0) { total, subscription in
                total + (subscription.price?.doubleValue ?? 0.0)
            }
    }

}

struct SubscriptionCardView: View {
    let subscription: SubscriptionEntity

    var body: some View {
        VStack {
                    VStack {
                        Image(subscription.logoName ?? "defaultLogo") // Placeholder for the subscription logo
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .background(subscriptionColor)
                            .cornerRadius(10)

                        Text("\(daysLeftTillBillingDate()) Days Left")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal)

                    Spacer() // Pushes the progress bar to the bottom

                    ProgressBar(value: daysLeftPercentage())
                        .frame(height: 10)
                        .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 100) // Set a minimum height for the card
                .background(subscriptionColor)
                .cornerRadius(20)
                .shadow(radius: 10)
            }

    private func daysLeftTillBillingDate() -> Int {
        guard let billingStartDate = subscription.billingDate else { return 0 }
        let billingCycleLength = 30 // Assuming a 30-day billing cycle for monthly subscriptions

        // Calculate the end date of the current billing cycle
        guard let billingEndDate = Calendar.current.date(byAdding: .day, value: billingCycleLength, to: billingStartDate) else { return 0 }

        // Calculate the number of days from today to the end date of the current billing cycle
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: billingEndDate).day ?? 0

        return max(daysLeft, 0) // Ensure it's not negative
    }


    private func daysLeftPercentage() -> Float {
        guard let billingDate = subscription.billingDate else { return 0 }
        let totalDays: Float = determineCycleLength(billingCycle: subscription.billingCycle)
        let daysLeft = Float(daysLeftTillBillingDate())
        return (daysLeft / totalDays).clamped(to: 0...1) // Clamped to ensure the value is between 0 and 1
    }

    private func determineCycleLength(billingCycle: String?) -> Float {
        switch billingCycle {
        case "Monthly":
            return 30 // Average number of days in a month
        case "Annual":
            return 365 // Number of days in a year
        case "Bi-Weekly":
            return 14 // Number of days in two weeks
        case "Weekly":
            return 7 // Number of days in a week
        default:
            return 30 // Default to monthly if unknown
        }
    }

    
    // Computed property to dynamically create a Color from subscription.backgroundColor
    var subscriptionColor: Color {
        // Here we should convert the hexColor string to a UIColor, and then to a SwiftUI Color
        // Assuming `backgroundColor` is a hex string stored in the SubscriptionEntity
        if let hexColor = subscription.backgroundColor, let uiColor = UIColor(hex: hexColor) {
            return Color(uiColor: uiColor)
        }
        return Color.gray // Default color if conversion fails
    }
}
extension Float {
    /// Clamps the floating point value to the provided range.
    func clamped(to range: ClosedRange<Float>) -> Float {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
// Custom progress bar
struct ProgressBar: View {
    var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(.white)
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(.white)
                    .animation(.linear, value: value)
            }.cornerRadius(45.0)
        }
    }
}

struct DashboardCardView: View {
    let title: String
    let detail: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                Text(detail)
                    .font(.title)
                    .bold()
            }
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

