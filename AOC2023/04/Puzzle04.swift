fileprivate struct Card: Hashable {
    let id, winningCount: Int

    init(id: Int, winningNumbers: Set<Int>, yourNumbers: Set<Int>) {
        self.id = id
        self.winningCount = yourNumbers.intersection(winningNumbers).count
    }

    static func parse(_ line: String) -> Self {
        var split = line.components(separatedBy: ":")
        let id = Int(split.first!.split(separator: " ").last!)!
        split = split.last!.components(separatedBy: "|")
        var (winningNumbers, yourNumbers) = (Set<Int>(), Set<Int>())
        for str in split.first!.split(separator: " ") {
            winningNumbers.insert(Int(str)!)
        }
        for str in split.last!.split(separator: " ") {
            yourNumbers.insert(Int(str)!)
        }
        return Card(id: id, winningNumbers: winningNumbers, yourNumbers: yourNumbers)
    }
}

struct Puzzle04: Puzzle {
    private let cards = InputFileReader.read("Input04").map(Card.parse(_:))

    func part1() {
        let sum = cards.map { 1 << ($0.winningCount - 1) }.reduce(0, +)
        print(sum)
    }

    func part2() {
        var cardCounts = Array(repeating: 1, count: cards.count)
        for index in cardCounts.indices {
            let winningCount = cards[index].winningCount
            if winningCount == 0 { continue }
            for i in (index+1...index+winningCount) {
                cardCounts[i] += cardCounts[index]
            }
        }
        print(cardCounts.reduce(0, +))
    }
}
