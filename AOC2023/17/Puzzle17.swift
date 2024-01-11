import HeapModule

fileprivate let costs = InputFileReader.read("Input17-test").map { $0.map(\.wholeNumberValue!) }

fileprivate enum Direction {
    case n, w, s, e
}

fileprivate class Node: Hashable, Comparable, CustomStringConvertible {
    let point: Point2D
    var priority: Int
    var direction: Direction?

    init(x: Int, y: Int) {
        self.point = Point2D(x: x, y: y)
        self.priority = 0
    }

    var cost: Int { costs[point.y][point.x] }
    var description: String { "\(point)" }
    static func < (lhs: Node, rhs: Node) -> Bool { lhs.priority < rhs.priority }
    static func == (lhs: Node, rhs: Node) -> Bool { lhs.point == rhs.point }
    func hash(into hasher: inout Hasher) { hasher.combine(point) }
    func distance(to: Node) -> Int { abs(point.x - to.point.x) + abs(point.y - to.point.y) }

    func neighbours() -> [Node] {
        [(1, 0, .e), (-1, 0, .w), (0, 1, .s), (0, -1, .n)].compactMap { (dx, dy, dir: Direction) in
            if isInRange(x: point.x + dx, y: point.y + dy) {
                let node = Node(x: point.x + dx, y: point.y + dy)
                node.direction = dir
                return node
            }
            return nil
        }
    }

    private func isInRange(x: Int, y: Int) -> Bool {
        costs.indices.contains(y) && costs[0].indices.contains(x)
    }
}


struct Puzzle17: Puzzle {
    // Doesn't handle 3 moves along same dir condition
    private func shortestPath(start: Node, end: Node) -> [Node] {
        var frontier = Heap([start])
        var cameFrom = [Node: Node]()
        var costsSoFar = [start: 0]

        while let node = frontier.popMin() {
            if node == end {
                return path(start: start, end: end, cameFrom: cameFrom)
            }
            for neighbour in node.neighbours() {
                var newCost = costsSoFar[node]! + neighbour.cost
                if newCost < costsSoFar[neighbour, default: Int.max] {
                    costsSoFar[neighbour] = newCost
                    neighbour.priority = newCost + neighbour.distance(to: end)
                    frontier.insert(neighbour)
                    cameFrom[neighbour] = node
                }
            }
        }
        return path(start: start, end: end, cameFrom: cameFrom)
    }

    private func path(start: Node, end: Node, cameFrom: [Node: Node]) -> [Node] {
        guard !cameFrom.isEmpty else { return [] }
        var current = end
        var path = [Node]()
        while current != start {
            path.append(current)
            current = cameFrom[current]!
        }
        print(path.count)
        return path.reversed()
    }

    func part1() {
        let start = Node(x: 0, y: 0)
        let end = Node(x: costs[0].endIndex - 1, y: costs.endIndex - 1)
        let heatLoss = shortestPath(start: start, end: end).reduce(0) { acc, node in
            print(node)
            return acc + node.cost
        }
        print(heatLoss) // Incorrect answer
    }

    func part2() {
        // TODO
    }
}
