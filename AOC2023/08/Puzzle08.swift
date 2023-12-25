private let regex = /(?<key>[A-Z0-9]{3}) = \((?<left>[A-Z0-9]{3}), (?<right>[A-Z0-9]{3})\)/

struct Puzzle08: Puzzle {
    private let directions: [Character]
    private let nodes: [String: (l: String, r: String)]

    init() {
        let input = InputFileReader.read("Input08")
        let nodes = input.dropFirst().map { line in
            let match = line.firstMatch(of: regex)!.output
            return (String(match.key), (String(match.left), String(match.right)))
        }
        self.directions = Array(input[0])
        self.nodes = Dictionary(uniqueKeysWithValues: nodes)
    }

    func part1() {
        let steps = stepCount(start: "AAA") { $0 == "ZZZ" }
        print(steps)
    }

    func part2() {
        let startNodes = nodes.keys.filter { $0.last! == "A" }
        let steps = startNodes.map { node in
            stepCount(start: node) { $0.last! == "Z" }
        }
        print(steps.reduce(1, lcm(_:_:)))
    }

    private func stepCount(start: String, end: (String) -> Bool) -> Int {
        var currentNode = start
        var count = 0
        var dir = directions[count % directions.count]
        while !end(currentNode) {
            currentNode = (dir == "L" ? nodes[currentNode]!.l : nodes[currentNode]!.r)
            count += 1
            dir = directions[count % directions.count]
        }
        return count
    }
}
