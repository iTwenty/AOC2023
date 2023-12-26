struct Puzzle09: Puzzle {
    private let histories = InputFileReader.read("Input09").map { line in
        line.components(separatedBy: " ").compactMap(Int.init)
    }

    func part1() {
        let extrapolatedValues = histories.map(extrapolatedValue(_:))
        print(extrapolatedValues.reduce(0, +))
    }

    func part2() {
        let extrapolatedValues = histories.map { extrapolatedValue($0.reversed()) }
        print(extrapolatedValues.reduce(0, +))
    }

    private func extrapolatedValue(_ seq: [Int]) -> Int {
        let triangle = sequence(first: seq) { input in
            if input.allSatisfy({ $0 == 0 }) { return nil }
            return zip(input.dropFirst(), input.dropLast()).map { (a, b) in
                return a - b
            }
        }
        return triangle.reduce(0) { $0 + $1.last! }
    }
}
