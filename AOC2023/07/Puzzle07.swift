fileprivate enum HandType: Int, Comparable {
    case highCard, onePair, twoPair, threeOfAKind,
         fullHouse, fourOfAKind, fiveOfAKind

    static func < (lhs: HandType, rhs: HandType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// 2 suffix in names is for part 2. No suffix implies part 1
fileprivate struct Hand: ExpressibleByStringLiteral {
    private static let cardStrengths = Array("23456789TJQKA")
    private static let cardStrengths2 = Array("J23456789TQKA")

    let cards: [Character]
    let type: HandType
    let type2: HandType

    init(stringLiteral: String) {
        self.cards = Array(stringLiteral)
        self.type = Self.deriveType(cards)
        self.type2 = Self.deriveType2(cards)
    }

    static func compare(lhs: Hand, rhs: Hand) -> Bool {
        if lhs.type == rhs.type {
            return Self.compareCards(lhs: lhs.cards, rhs: rhs.cards, cardStrengths: cardStrengths)
        } else {
            return lhs.type < rhs.type
        }
    }

    static func compare2(lhs: Hand, rhs: Hand) -> Bool {
        if lhs.type2 == rhs.type2 {
            return Self.compareCards(lhs: lhs.cards, rhs: rhs.cards, cardStrengths: cardStrengths2)
        } else {
            return lhs.type2 < rhs.type2
        }
    }

    private static func compareCards(lhs: some Collection<Character>, rhs: some Collection<Character>, cardStrengths: [Character]) -> Bool {
        guard let lhsFirst = lhs.first, let rhsFirst = rhs.first else {
            return false
        }
        if lhs.first == rhs.first {
            return Self.compareCards(lhs: lhs.dropFirst(), rhs: rhs.dropFirst(), cardStrengths: cardStrengths)
        } else {
            return cardStrengths.firstIndex(of: lhsFirst)! < cardStrengths.firstIndex(of: rhsFirst)!
        }
    }

    private static func deriveType(_ cards: [Character]) -> HandType {
        let counts = Dictionary(grouping: cards) { $0 }.map { $1.count }.sorted()
        switch counts {
        case [5]: return .fiveOfAKind
        case [1, 4]: return .fourOfAKind
        case [2, 3]: return .fullHouse
        case [1, 1, 3]: return .threeOfAKind
        case [1, 2, 2]: return .twoPair
        case [1, 1, 1, 2]: return .onePair
        case [1, 1, 1, 1, 1]: return .highCard
        default: fatalError("Bogus hand \(cards)")
        }
    }

    private static func deriveType2(_ cards: [Character]) -> HandType {
        let counts = Dictionary(grouping: cards) { $0 }.map { $1.count }.sorted()
        let js = cards.filter { $0 == "J" }
        switch counts {
        case [5]: return .fiveOfAKind
        case [1, 4]: return js.isEmpty  ? .fourOfAKind : .fiveOfAKind
        case [2, 3]: return js.isEmpty ? .fullHouse : .fiveOfAKind
        case [1, 1, 3]: return js.isEmpty ? .threeOfAKind : .fourOfAKind
        case [1, 2, 2]: return js.count == 2 ? .fourOfAKind : (js.count == 1 ? .fullHouse : .twoPair)
        case [1, 1, 1, 2]: return js.isEmpty ? .onePair : .threeOfAKind
        case [1, 1, 1, 1, 1]: return js.isEmpty ? .highCard : .onePair
        default: fatalError("Bogus hand \(cards)")
        }
    }
}

struct Puzzle07: Puzzle {
    private let bids: [(Hand, Int)]

    init() {
        self.bids = InputFileReader.read("Input07").map { line in
            let split = line.components(separatedBy: " ")
            return (Hand(stringLiteral: split.first!), Int(split.last!)!)
        }
    }

    func part1() {
        let sortedBids = self.bids.sorted { lhs, rhs in
            Hand.compare(lhs: lhs.0, rhs: rhs.0)
        }.map(\.1)
        print(calculateWinnings(sortedBids))
    }

    func part2() {
        let sortedBids = self.bids.sorted { lhs, rhs in
            Hand.compare2(lhs: lhs.0, rhs: rhs.0)
        }.map(\.1)
        print(calculateWinnings(sortedBids))
    }

    private func calculateWinnings(_ sortedBids: [Int]) -> Int {
        return sortedBids.enumerated().reduce(0) { acc, tuple in
            let (index, bid) = tuple
            return acc + ((index + 1) * bid)
        }
    }
}
