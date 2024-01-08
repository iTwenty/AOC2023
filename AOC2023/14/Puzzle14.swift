fileprivate enum Direction {
    case n, s, e, w
}

fileprivate struct Grid: Hashable {
    let chars: [[Character]]

    private func findNextFixedIndex(current: Int, chars: [Character]) -> Int {
        if current == chars.endIndex { return chars.endIndex }
        for i in current+1..<chars.endIndex {
            if chars[i] == "#" {
                return i
            }
        }
        return chars.endIndex
    }

    private func slide(chars: [Character], _ direction: Direction) -> [Character] {
        var newChars = [Character]()
        var currentFixedIndex = -1
        repeat {
            let nextFixedIndex = findNextFixedIndex(current: currentFixedIndex, chars: chars)
            let currentRange = currentFixedIndex+1..<nextFixedIndex
            let roundedCount = chars[currentRange].filter { $0 == "O" }.count
            let emptyCount = chars[currentRange].filter { $0 == "." }.count
            if [.n, .w].contains(direction) {
                newChars.append(contentsOf: Array(repeating: "O", count: roundedCount))
                newChars.append(contentsOf: Array(repeating: ".", count: emptyCount))
            } else {
                newChars.append(contentsOf: Array(repeating: ".", count: emptyCount))
                newChars.append(contentsOf: Array(repeating: "O", count: roundedCount))
            }
            newChars.append("#")
            currentFixedIndex = nextFixedIndex
        } while currentFixedIndex < chars.endIndex
        return newChars
    }

    func slide(_ direction: Direction) -> Grid {
        if [.n, .s].contains(direction) {
            var newChars = Array(repeating: [Character](), count: chars.count)
            for colIndex in chars[0].indices {
                let col = chars.map { $0[colIndex] }
                let newCol = slide(chars: col, direction)
                for rowIndex in chars.indices {
                    newChars[rowIndex].append(newCol[rowIndex])
                }
            }
            return Grid(chars: newChars)
        } else {
            var newChars = [[Character]]()
            for row in chars {
                let newRow = slide(chars: row, direction)
                newChars.append(Array(newRow[row.startIndex..<row.endIndex]))
            }
            return Grid(chars: newChars)
        }
    }

    func cycle() -> Grid {
        var newGrid = self
        [.n, .w, .s, .e].forEach { direction in
            newGrid = newGrid.slide(direction)
        }
        return newGrid
    }

    func load() -> Int {
        chars.enumerated().reduce(0) { acc, element in
            let (index, row) = element
            return acc + (row.filter { $0 == "O" }.count * (chars.count - index))
        }
    }
}

struct Puzzle14: Puzzle {
    private let grid = Grid(chars: InputFileReader.read("Input14").map(Array.init))

    func part1() {
        print(grid.slide(.n).load())
    }

    func part2() {
        var current = grid
        var seen = [Grid: Int]()
        var (loopStartIndex, loopEndIndex) = (0, 0)
        for i in 1... {
            current = current.cycle()
            if let index = seen[current] {
                loopStartIndex = index
                loopEndIndex = i
                break
            }
            seen[current] = i
        }
        let cycles = 1000000000
        let grid = seen.filter { (key: Grid, index: Int) in
            index == (cycles - loopStartIndex) % (loopEndIndex - loopStartIndex) + loopStartIndex
        }.first!.key
        print(grid.load())
    }
}
