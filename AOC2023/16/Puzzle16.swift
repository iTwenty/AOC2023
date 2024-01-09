fileprivate enum Direction {
    case n, w, s, e
}

fileprivate struct Beam: Hashable {
    var head: Point2D
    var direction: Direction

    mutating func move() {
        switch direction {
        case .n: head = head - Point2D(x: 0, y: 1)
        case .w: head = head - Point2D(x: 1, y: 0)
        case .s: head = head + Point2D(x: 0, y: 1)
        case .e: head = head + Point2D(x: 1, y: 0)
        }
    }

    mutating func updateDirection(_ char: Character) {
        switch (direction, char) {
        case (.n, "/"): self.direction = .e
        case (.n, "\\"): self.direction = .w
        case (.w, "/"): self.direction = .s
        case (.w, "\\"): self.direction = .n
        case (.s, "/"): self.direction = .w
        case (.s, "\\"): self.direction = .e
        case (.e, "/"): self.direction = .n
        case (.e, "\\"): self.direction = .s
        default: break
        }
    }
}

struct Puzzle16: Puzzle {
    private let grid = InputFileReader.read("Input16").map(Array.init)

    private func advance(beam: inout Beam, seen: inout Set<Beam>) -> [Beam] {
        while !seen.contains(beam), grid.indices.contains(beam.head.y), grid[0].indices.contains(beam.head.x) {
            seen.insert(beam)
            let char = grid[beam.head.y][beam.head.x]
            if ("/\\.").contains(char) ||
                ((char == "-") && [.e, .w].contains(beam.direction)) ||
                ((char == "|") && [.n, .s].contains(beam.direction)) {
                // No split needed. Update beam direction and position
                beam.updateDirection(char)
                beam.move()
            } else if char == "-" { // direction is n or s. Split into e and w
                return [Beam(head: beam.head + Point2D(x: 1, y: 0), direction: .e),
                        Beam(head: beam.head - Point2D(x: 1, y: 0), direction: .w)]
            } else { // char is "|" and direction is e or w. Split into n and s
                return [Beam(head: beam.head + Point2D(x: 0, y: 1), direction: .s),
                        Beam(head: beam.head - Point2D(x: 0, y: 1), direction: .n)]
            }
        }
        return [] // Beam is already seen, or beam falls outside grid bounds.
    }

    private func energize(start: Beam) -> Int {
        var seen = Set<Beam>()
        var beams = [start]
        while var beam = beams.popLast() {
            beams.append(contentsOf: advance(beam: &beam, seen: &seen))
        }
        var energized = Set<Point2D>()
        seen.forEach { energized.insert($0.head) }
        return energized.count
    }

    func part1() {
        print(energize(start: Beam(head: Point2D(x: 0, y: 0), direction: .e)))
    }

    func part2() {
        let ewMax = grid.indices.reduce(0) { curMax, y in
            let energizedEast = energize(start: Beam(head: Point2D(x: 0, y: y), direction: .e))
            let energizedWest = energize(start: Beam(head: Point2D(x: grid[0].endIndex - 1, y: y), direction: .w))
            return max(curMax, energizedEast, energizedWest)
        }
        let nsMax = grid[0].indices.reduce(0) { curMax, x in
            let energizedNorth = energize(start: Beam(head: Point2D(x: x, y: grid.endIndex - 1), direction: .n))
            let energizedSouth = energize(start: Beam(head: Point2D(x: x, y: 0), direction: .s))
            return max(curMax, energizedNorth, energizedSouth)
        }
        print(max(ewMax, nsMax))
    }
}
