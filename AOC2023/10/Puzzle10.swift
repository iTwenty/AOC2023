fileprivate enum Tile: Character, CustomStringConvertible {
    case ns = "|", ew = "-", ne = "L", nw = "J", sw = "7", se = "F", gr = ".", st = "S"
    var description: String { "\(rawValue)" }
    static let N: Set<Tile> = [.ns, .ne, .nw]
    static let S: Set<Tile> = [.ns, .se, .sw]
    static let E: Set<Tile> = [.ew, .ne, .se]
    static let W: Set<Tile> = [.ew, .nw, .sw]
}

fileprivate struct Grid {
    private let tiles: [[Tile]]
    let start: Point2D

    init(tiles: [[Character]]) {
        self.tiles = tiles.map { $0.map { Tile(rawValue: $0)! } }
        self.start = Self.findStart(self.tiles)
    }

    private static func findStart(_ tiles: [[Tile]]) -> Point2D {
        for (y, row) in tiles.enumerated() {
            for (x, tile) in row.enumerated() {
                if tile == .st {
                    return Point2D(x: x, y: y)
                }
            }
        }
        fatalError("No S tile found!")
    }

    private func isInRange(_ position: Point2D) -> Bool {
        tiles[0].indices.contains(position.x) && tiles.indices.contains(position.y)
    }

    private func isConnected(tilePos: Point2D, neighbourPos: Point2D,
                             tiles: Set<Tile>, neighbours: Set<Tile>) -> Bool {
        guard isInRange(tilePos), isInRange(neighbourPos) else { return false }
        let tile = self.tiles[tilePos.y][tilePos.x]
        let neighbour = self.tiles[neighbourPos.y][neighbourPos.x]
        if tile == .st {
            return neighbours.contains(neighbour)
        } else {
            return tiles.contains(tile) && neighbours.contains(neighbour)
        }
    }

    func neighbours(_ tilePos: Point2D) -> [Point2D] {
        let nPos = tilePos - Point2D(x: 0, y: 1)
        let sPos = tilePos + Point2D(x: 0, y: 1)
        let wPos = tilePos - Point2D(x: 1, y: 0)
        let ePos = tilePos + Point2D(x: 1, y: 0)
        var connectedNeighbours = [Point2D]()
        if isConnected(tilePos: tilePos, neighbourPos: nPos, tiles: Tile.N, neighbours: Tile.S) {
            connectedNeighbours.append(nPos)
        }
        if isConnected(tilePos: tilePos, neighbourPos: sPos, tiles: Tile.S, neighbours: Tile.N) {
            connectedNeighbours.append(sPos)
        }
        if isConnected(tilePos: tilePos, neighbourPos: wPos, tiles: Tile.W, neighbours: Tile.E) {
            connectedNeighbours.append(wPos)
        }
        if isConnected(tilePos: tilePos, neighbourPos: ePos, tiles: Tile.E, neighbours: Tile.W) {
            connectedNeighbours.append(ePos)
        }
        return connectedNeighbours
    }

    func bfs() -> [Point2D: Int] {
        var stack = [(self.start, 0)]
        var visited = [Point2D: Int]()
        while let (current, distance) = stack.first {
            stack.remove(at: stack.startIndex)
            if visited.keys.contains(current) { continue }
            visited[current] = distance
            for neigbour in neighbours(current) {
                stack.append((neigbour, distance + 1))
            }
        }
        return visited
    }
}

struct Puzzle10: Puzzle {
    private let grid = Grid(tiles: InputFileReader.read("Input10").map(Array.init))

    func part1() {
        print(grid.bfs().values.max()!)
    }

    func part2() {
        // TODO
    }
}
