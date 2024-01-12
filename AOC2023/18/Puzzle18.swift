fileprivate let dirHexMap: [Character: Character] = ["0": "R", "1": "D", "2": "L", "3": "U"]

fileprivate struct Instruction: ExpressibleByStringLiteral {
    private let dir: Character
    private let dirHex: Character
    private let size: Int
    private let sizeHex: Int

    init(stringLiteral value: StringLiteralType) {
        let split = value.components(separatedBy: " ")
        dir = split[0].first!
        size = Int(split[1])!
        let hex = String(split[2].dropFirst(2).dropLast())
        dirHex = dirHexMap[hex.last!]!
        sizeHex = Int(hex.prefix(5), radix: 16)!
    }

    func direction(_ p2: Bool) -> Character { p2 ? dirHex : dir }
    func size(_ p2: Bool) -> Int { p2 ? sizeHex : size }
}

struct Puzzle18: Puzzle {
    private let instructions = InputFileReader.read("Input18").map(Instruction.init(stringLiteral:))

    private func boundaryPoint(_ start: Point2D, _ instruction: Instruction, _ p2: Bool) -> Point2D {
        let meters = instruction.size(p2)
        switch instruction.direction(p2) {
        case "L": return Point2D(x: start.x - meters, y: start.y)
        case "R": return Point2D(x: start.x + meters, y: start.y)
        case "U": return Point2D(x: start.x, y: start.y - meters)
        case "D": return Point2D(x: start.x, y: start.y + meters)
        default: fatalError("Invalid instruction \(instruction)")
        }
    }

    private func area(_ points: [Point2D], perimeter: Int) -> Int {
        var area = 0
        for i in points.indices {
            let a = points[i]
            let b = points[(i+1) % points.endIndex]
            area += (a.x * b.y - a.y * b.x)
        }
        return (area + perimeter) / 2 + 1
    }

    private func lagoonSize(_ p2: Bool) -> Int {
        var boundaries = [Point2D(x: 0, y: 0)]
        var perimeter = 0
        for instruction in instructions {
            perimeter += instruction.size(p2)
            boundaries.append(boundaryPoint(boundaries.last!, instruction, p2))
        }
        return area(boundaries, perimeter: perimeter)
    }

    func part1() {
        print(lagoonSize(false))
    }

    func part2() {
        print(lagoonSize(true))
    }
}
