import Algorithms

struct Puzzle12: Puzzle {
    private let input: [(spring: String, groups: [Int])]
    private static var cache = [String: Int]()

    init() {
        input = InputFileReader.read("Input12").map { line in
            let split = line.components(separatedBy: " ")
            let spring = split.first!
            let groups = split.last!.components(separatedBy: ",").map { Int($0)! }
            return (spring, groups)
        }
    }

    private func springCount(_ spring: String, _ groups: [Int]) -> Int {
        if groups.isEmpty { return spring.contains("#") ? 0 : 1 }
        if spring.isEmpty { return 0 }

        let cacheKey = "\(spring) \(groups.map(String.init).joined(separator: ","))"
        if let cached = Self.cache[cacheKey] { return cached }

        var count = 0
        let firstChar = spring.first!
        let firstGroup = groups.first!
        if firstChar == "." || firstChar == "?" {
            count += springCount(String(spring.dropFirst()), groups)
        }
        if (firstChar == "#" || firstChar == "?") && 
            firstGroup <= spring.count &&
            !spring.prefix(firstGroup).contains(".") &&
            (firstGroup == spring.count || spring.prefix(firstGroup + 1).last! != "#") {
            count += springCount(String(spring.dropFirst(firstGroup + 1)), Array(groups.dropFirst()))
        }
        Self.cache[cacheKey] = count
        return count
    }

    func part1() {
        let count = input.map { springCount($0.0, $0.1) }.reduce(0, +)
        print(count)
    }

    func part2() {
        let count = input.map { (spring: String, groups: [Int]) in
            let expandedSpring = String(spring.appending("?").cycled(times: 5).dropLast())
            let expandedGroups = Array(groups.cycled(times: 5))
            return springCount(expandedSpring, expandedGroups)
        }.reduce(0, +)
        print(count)
    }
}
