import SwiftUI

// MARK: - Models
struct BankCard: Identifiable {
    let id = UUID()
    var name: String
    var balance: Double
    var cardNumber: String
    var cashbackPercent: Double
    var vatPercent: Double
    var color1: Color
    var color2: Color
    // per-card transactions (mədaxil / məxaric)
    var transactions: [CardTransaction] = []
}

// implement Equatable manually (compare by id) to avoid Color non-Equatable problem
extension BankCard: Equatable {
    static func == (lhs: BankCard, rhs: BankCard) -> Bool {
        return lhs.id == rhs.id
    }
}

struct CardTransaction: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let title: String
    let amount: Double // positive = income (mədaxil), negative = expense (məxaric)
}

// MARK: - App entry
@main
struct BankApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - ContentView (TabView)
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var cards: [BankCard] = [
        BankCard(
            name: "Visa Gold",
            balance: 1260.45,
            cardNumber: "1234 5678 9012 3456",
            cashbackPercent: 3.0,
            vatPercent: 1.5,
            color1: .blue,
            color2: .purple,
            transactions: [
                CardTransaction(date: Date().addingTimeInterval(-3600*24*3), title: "Market", amount: -23.50),
                CardTransaction(date: Date().addingTimeInterval(-3600*24*5), title: "Maaş", amount: +450.0)
            ]
        ),
        BankCard(
            name: "Master Titanium",
            balance: 432.80,
            cardNumber: "9876 5432 1098 7654",
            cashbackPercent: 1.8,
            vatPercent: 0.7,
            color1: .orange,
            color2: .pink,
            transactions: [
                CardTransaction(date: Date().addingTimeInterval(-3600*2), title: "Kafe", amount: -14.9)
            ]
        ),
        BankCard(
            name: "Digital Card",
            balance: 980.10,
            cardNumber: "5678 1122 3344 5566",
            cashbackPercent: 2.5,
            vatPercent: 1.2,
            color1: .green,
            color2: .teal,
            transactions: []
        )
    ]
    @State private var selectedCard: BankCard? = nil

    var body: some View {
        TabView(selection: $selectedTab) {
            homeTab
                .tabItem { Label("Ana ekran", systemImage: "house.fill") }
                .tag(0)

            historyTab
                .tabItem { Label("Tarixçə", systemImage: "clock.fill") }
                .tag(1)

            discoverTab
                .tabItem { Label("Kəşf et", systemImage: "sparkles") }
                .tag(2)

            moreTab
                .tabItem { Label("Daha çox", systemImage: "ellipsis.circle.fill") }
                .tag(3)
        }
        // sheet tied to selectedCard (Identifiable + Equatable)
        .sheet(item: $selectedCard) { card in
            if let index = cards.firstIndex(of: card) {
                CardDetailView(card: $cards[index])
            } else {
                EmptyView()
            }
        }
    }

    // MARK: - Home tab view
    var homeTab: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Profile row
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 52, height: 52)
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Xoş gəlmisiniz,")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Zamin müəllim 👋")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Horizontal card slider
                GeometryReader { geo in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(cards) { card in
                                CardView(card: card)
                                    .frame(width: min(340, geo.size.width * 0.85), height: 200)
                                    .onTapGesture {
                                        selectedCard = card
                                    }
                            }

                            // Add card tile
                            AddCardTile {
                                addCard()
                            }
                            .frame(width: min(340, geo.size.width * 0.85), height: 200)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .frame(height: 220)

                // Quick last transactions preview (global)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Son əməliyyatlar")
                            .font(.headline)
                        Spacer()
                        Button("Hamısını gör") {
                            selectedTab = 1
                        }
                        .font(.caption)
                    }

                    // Show up to 3 most recent across all cards
                    let recent = cards.flatMap { $0.transactions.map { $0 } }
                        .sorted { $0.date > $1.date }
                    ForEach(Array(recent.prefix(3))) { tx in
                        TransactionRow(title: tx.title, subtitle: tx.date.formatted(.dateTime.month().day().year()), amount: tx.amount)
                    }
                    if recent.isEmpty {
                        Text("Hələlik əməliyyat yoxdur.")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - History tab (shows full history grouped by card)
    var historyTab: some View {
        NavigationView {
            List {
                ForEach(cards) { card in
                    Section(header: HStack {
                        Text(card.name).fontWeight(.semibold)
                        Spacer()
                        Text(String(format: "%.2f AZN", card.balance)).foregroundColor(.secondary)
                    }) {
                        if card.transactions.isEmpty {
                            Text("Tarixçə yoxdur").foregroundColor(.secondary)
                        } else {
                            ForEach(card.transactions) { tx in
                                TransactionRow(title: tx.title, subtitle: tx.date.formatted(.dateTime.month().day().year()), amount: tx.amount)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Tarixçə")
        }
    }

    // MARK: - Discover tab
    var discoverTab: some View {
        NavigationView {
            VStack {
                Text("Kəşf et")
                    .font(.title2).bold()
                    .padding()
                Spacer()
                Text("Endirimlər və kampaniyalar burada olacaq.")
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }

    // MARK: - More tab
    var moreTab: some View {
        NavigationView {
            VStack {
                Text("Daha çox")
                    .font(.title2).bold()
                    .padding()
                Spacer()
                Text("Tənzimləmələr və profil məlumatları.")
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }

    // MARK: - Helpers
    private func addCard() {
        let new = BankCard(
            name: "Yeni Kart",
            balance: 0.0,
            cardNumber: String(format: "XXXX XXXX XXXX %04d", Int.random(in: 0...9999)),
            cashbackPercent: Double.random(in: 0.5...5.0).rounded(toPlaces: 1),
            vatPercent: Double.random(in: 0.3...3.0).rounded(toPlaces: 1),
            color1: [.blue, .indigo, .teal, .pink].randomElement() ?? .blue,
            color2: [.purple, .mint, .orange, .green].randomElement() ?? .purple,
            transactions: []
        )
        withAnimation { cards.append(new) }
    }
}

// MARK: - Card view (visual)
struct CardView: View {
    let card: BankCard

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [card.color1, card.color2], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(card.name)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        Text(String(format: "%.2f AZN", card.balance))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "wave.3.right.circle.fill")
                        .foregroundColor(.white.opacity(0.9))
                }

                HStack(spacing: 12) {
                    metricPill(title: "Cashback", value: String(format: "%.1f%%", card.cashbackPercent))
                    Spacer()
                    metricPill(title: "ƏDV", value: String(format: "%.1f%%", card.vatPercent))
                }

                Spacer()

                Text(card.cardNumber)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func metricPill(title: String, value: String) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption2).foregroundColor(.white.opacity(0.85))
                Text(value).font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.12))
        .cornerRadius(10)
    }
}

// MARK: - Add tile
struct AddCardTile: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray6))
                    .shadow(radius: 4)
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    Text("Kart əlavə et")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Card detail view (bound to the card in array)
struct CardDetailView: View {
    @Binding var card: BankCard
    @Environment(\.dismiss) var dismiss
    @State private var showPay = false
    @State private var showTransfer = false
    @State private var showQR = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray.opacity(0.3))
                    .padding(.top, 8)

                Text(card.name)
                    .font(.title2).bold()

                CardView(card: card)
                    .frame(height: 160)
                    .padding(.horizontal)

                Text("Balans: \(String(format: "%.2f", card.balance)) AZN")
                    .font(.headline)

                // Action buttons
                HStack(spacing: 20) {
                    VStack {
                        Button(action: { showPay = true }) {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 64, height: 64)
                                .overlay(Image(systemName: "creditcard.fill").foregroundColor(.blue))
                        }
                        Text("Ödə").font(.caption)
                    }

                    VStack {
                        Button(action: { showTransfer = true }) {
                            Circle()
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 64, height: 64)
                                .overlay(Image(systemName: "arrow.right.arrow.left.circle.fill").foregroundColor(.green))
                        }
                        Text("Köçür").font(.caption)
                    }

                    VStack {
                        Button(action: { showQR = true }) {
                            Circle()
                                .fill(Color.orange.opacity(0.15))
                                .frame(width: 64, height: 64)
                                .overlay(Image(systemName: "qrcode.viewfinder").foregroundColor(.orange))
                        }
                        Text("QR Skan").font(.caption)
                    }
                }
                .padding(.top, 6)

                Divider().padding(.vertical, 8)

                // Mədaxil / Məxaric tarixçəsi (per-card)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tarixçə")
                        .font(.headline)
                    if card.transactions.isEmpty {
                        Text("Hələlik əməliyyat yoxdur").foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        List {
                            ForEach(card.transactions.sorted { $0.date > $1.date }) { tx in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(tx.title).fontWeight(.semibold)
                                        Text(tx.date.formatted(.dateTime.month().day().year().hour().minute())).font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("\(tx.amount >= 0 ? "+" : "")\(String(format: "%.2f", tx.amount)) AZN")
                                        .foregroundColor(tx.amount >= 0 ? .green : .red)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .frame(height: 220)
                        .listStyle(.plain)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.bottom)
            .navigationBarItems(trailing: Button("Bağla") { dismiss() })
            .navigationBarTitleDisplayMode(.inline)
            // MARK: - Sheets for actions
            .sheet(isPresented: $showPay) {
                SimpleAmountSheet(title: "Ödə", primaryColor: .blue) { value in
                    addTransaction(title: "Ödə", amount: -value)
                    showPay = false
                }
            }
            .sheet(isPresented: $showTransfer) {
                SimpleAmountSheet(title: "Köçür", primaryColor: .green) { value in
                    addTransaction(title: "Köçürmə", amount: -value)
                    showTransfer = false
                }
            }
            .sheet(isPresented: $showQR) {
                QRMockView()
            }
        }
    }

    private func addTransaction(title: String, amount: Double) {
        // update balance and push transaction
        card.balance += amount
        let tx = CardTransaction(date: Date(), title: title, amount: amount)
        card.transactions.insert(tx, at: 0)
    }
}

// MARK: - Simple sheet for entering amount (used by Ödə / Köçür)
struct SimpleAmountSheet: View {
    let title: String
    let primaryColor: Color
    var onComplete: (Double) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var amountText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text(title).font(.title2).bold().padding(.top)
                TextField("Məbləği daxil edin", text: $amountText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                Spacer()
                Button(action: {
                    let val = Double(amountText) ?? 0
                    if val > 0 {
                        onComplete(val)
                        dismiss()
                    }
                }) {
                    Text("Təsdiq et")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(primaryColor)
                .padding()
            }
            .navigationBarItems(leading: Button("Bağla") { dismiss() })
        }
    }
}

// MARK: - Mock QR screen
struct QRMockView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("QR Skan (demo)")
                    .font(.title2).bold()
                RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2))
                    .frame(width: 220, height: 220)
                    .overlay(Image(systemName: "qrcode").font(.system(size: 60)).foregroundColor(.gray))
                Text("Bu demo skan ekranıdır.")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Bağla") { dismiss() })
        }
    }
}

// MARK: - TransactionRow reusable
struct TransactionRow: View {
    let title: String
    let subtitle: String
    let amount: Double

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title).fontWeight(.semibold)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Text("\(amount >= 0 ? "+" : "")\(String(format: "%.2f", amount)) AZN")
                .foregroundColor(amount >= 0 ? .green : .red)
                .bold()
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Helpers
fileprivate extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let mult = pow(10.0, Double(places))
        return (self * mult).rounded() / mult
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
