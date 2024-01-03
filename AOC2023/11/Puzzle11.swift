import Algorithms

struct Puzzle11: Puzzle {
    private let emptyRows: [Int]
    private let emptyCols: [Int]
    private let galaxyPairs: CombinationsSequence<[Point2D]>

    init() {
        let original = InputFileReader.read("Input11").map(Array.init)
        let emptyRows = original.indices.filter { !original[$0].contains("#") }
        let emptyCols = original[0].indices.filter { index in
            let col = original.map { row in row[index] }
            return !col.contains("#")
        }
        self.emptyRows = emptyRows
        self.emptyCols = emptyCols
        self.galaxyPairs = Self.galaxies(original).combinations(ofCount: 2)
    }

    private static func galaxies(_ universe: [[Character]]) -> [Point2D] {
        var positions = [Point2D]()
        for (y, row) in universe.enumerated() {
            for (x, cell) in row.enumerated() {
                if cell == "#" {
                    positions.append(Point2D(x: x, y: y))
                }
            }
        }
        return positions
    }

    private func distance(_ lhs: Point2D, _ rhs: Point2D, scale: Int) -> Int {
        var diffX = abs(lhs.x - rhs.x)
        let emptyColsCount = (min(lhs.x, rhs.x)..<max(lhs.x, rhs.x)).filter { x in
            emptyCols.contains(x)
        }.count
        diffX = diffX + (emptyColsCount * (scale - 1))

        var diffY = abs(lhs.y - rhs.y)
        let emptyRowsCount = (min(lhs.y, rhs.y)..<max(lhs.y, rhs.y)).filter { y in
            emptyRows.contains(y)
        }.count
        diffY = diffY + (emptyRowsCount * (scale - 1))
        return diffX + diffY
    }

    func part1() {
        let scale = 2
        let sum = galaxyPairs.reduce(0) { acc, points in
            acc + distance(points.first!, points.last!, scale: scale)
        }
        print(sum)
    }

    func part2() {
        let scale = 1000000
        let sum = galaxyPairs.reduce(0) { acc, points in
            acc + distance(points.first!, points.last!, scale: scale)
        }
        print(sum)
    }
}
