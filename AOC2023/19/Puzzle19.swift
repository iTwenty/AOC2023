fileprivate typealias Part = [Int] //Array of 4 ints : [x,m,a,s]
fileprivate typealias PartRange = [ClosedRange<Int>] //Array of 4 Ranges : [xR,mR,aR,sR]
fileprivate let map: [Character: Int] = ["x": 0, "m": 1, "a": 2, "s": 3]

fileprivate struct Rule {
    let cond: String?
    let dest: String

    func applyTo(_ part: Part) -> Bool {
        guard let cond else { return true }
        let index = map[cond.first!]!
        let check = cond[cond.index(after: cond.startIndex)]
        let value = Int(cond.dropFirst(2))!
        return (check == "<" && part[index] < value) || (check == ">" && part[index] > value)
    }

    func applyTo(_ partRange: PartRange) -> (PartRange, PartRange) {
        guard let cond else { return (partRange, Array(repeating: (0...0), count: 4)) }
        let index = map[cond.first!]!
        let check = cond[cond.index(after: cond.startIndex)]
        let value = Int(cond.dropFirst(2))!

        let rangeToSplit = partRange[index]
        guard rangeToSplit.contains(value) else {
            fatalError("Value \(value) not in range \(rangeToSplit)")
        }
        if check == "<" {
            let a = (rangeToSplit.first!...value-1)
            let b = (value...rangeToSplit.last!)
            let matched = partRange.enumerated().map { (i, range) in
                i == index ? a : range
            }
            let unmatched = partRange.enumerated().map { (i, range) in
                i == index ? b : range
            }
            return (matched, unmatched)
        } else {
            let a = (value+1...rangeToSplit.last!)
            let b = (rangeToSplit.first!...value)
            let matched = partRange.enumerated().map { (i, range) in
                i == index ? a : range
            }
            let unmatched = partRange.enumerated().map { (i, range) in
                i == index ? b : range
            }
            return (matched, unmatched)
        }
    }
}

struct Puzzle19: Puzzle {
    private let workflows: [String: [Rule]]
    private let parts: [Part]

    init() {
        var workflows = [String: [Rule]]()
        var parts = [Part]()
        var parseWorkflows = true
        for line in InputFileReader.read("Input19", omitEmptySubsequences: false) {
            if line.isEmpty {
                parseWorkflows = false
                continue
            }
            if parseWorkflows {
                let parsed = Self.parseWorkflow(line)
                workflows[parsed.0] = parsed.1
            } else {
                parts.append(Self.parsePart(line))
            }
        }
        self.workflows = workflows
        self.parts = parts
    }

    private static func parseWorkflow(_ line: String) -> (String, [Rule]) {
        var split = line.components(separatedBy: "{")
        let name = split[0]
        split = split[1].dropLast().components(separatedBy: ",")
        return (name, split.map(Self.parseRule(_:)))
    }

    private static func parseRule(_ str: String) -> Rule {
        let split = str.components(separatedBy: ":")
        if split.count == 2 {
            return Rule(cond: split[0], dest: split[1])
        } else {
            return Rule(cond: nil, dest: split[0])
        }
    }

    private static func parsePart(_ line: String) -> [Int] {
        line.dropFirst().dropLast().components(separatedBy: ",").map { str in
            Int(str.dropFirst(2))!
        }
    }

    private func process(_ part: Part) -> Bool {
        var current = workflows["in"]!

        while true {
            for rule in current {
                guard rule.applyTo(part) else { continue }
                if rule.dest == "A" { return true }
                if rule.dest == "R" { return false }
                current = workflows[rule.dest]!
                break
            }
        }
    }

    func part1() {
        let sum = parts.reduce(0) { acc, part in
            process(part) ? acc + part.reduce(0, +) : acc
        }
        print(sum)
    }

    func part2() {
        let all = Array(repeating: (1...4000), count: 4)
        var acceptedCount = 0
        var dests = ["in"]
        var matchingRanges = ["in": all]
        while let current = dests.popLast() {
            for rule in workflows[current]! {
                let (matched, unmatched) = rule.applyTo(matchingRanges[current]!)
                matchingRanges[current] = unmatched // Unmatched to be checked again in next rule
                if rule.dest == "A" {
                    acceptedCount += (matched.reduce(1, {  $0 * $1.count }))
                } else if rule.dest != "R" {
                    matchingRanges[rule.dest] = matched
                    dests.append(rule.dest)
                }
            }
        }
        print(acceptedCount)
    }
}
