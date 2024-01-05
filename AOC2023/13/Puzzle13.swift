fileprivate struct Pattern {
    let chars: [[Character]]

    func findMirror(tolerance: Int) -> (index: Int, row: Bool)? {
        if let mirrorRow = findMirror(row: true, tolerance: tolerance) {
            return (mirrorRow, true)
        } else if let mirrorCol = findMirror(row: false, tolerance: tolerance) {
            return (mirrorCol, false)
        }
        return nil
    }

    private func findMirror(row: Bool, tolerance: Int) -> Int? {
        let startIndex = (row ? chars.startIndex : chars[0].startIndex)
        let endIndex = (row ? chars.endIndex: chars[0].endIndex) - 1
        for i in startIndex...endIndex {
            var j = endIndex
            while i < j {
                if (i == startIndex || j == endIndex), allMatch(start: i, end: j, row: row, tolerance: tolerance) {
                    return (i + j) / 2
                } else {
                    j -= 1
                }
            }
        }
        return nil
    }

    private func allMatch(start: Int, end: Int, row: Bool, tolerance: Int) -> Bool {
        var s = start, e = end
        var differenceCount = 0
        while s < e {
            let firstGroup = (row ? chars[s] : chars.map({ $0[s] }))
            let secondGroup = (row ? chars[e] : chars.map({ $0[e] }))
            differenceCount += zip(firstGroup, secondGroup).filter({ $0 != $1 }).count
            if differenceCount <= tolerance {
                s += 1
                e -= 1
            } else {
                return false
            }
        }
        return !(s == e) && differenceCount == tolerance
    }
}

struct Puzzle13: Puzzle {
    private let patterns: [Pattern]

    init() {
        var patterns = [Pattern]()
        var currentChars = [[Character]]()
        for line in InputFileReader.read("Input13", omitEmptySubsequences: false) {
            if line.isEmpty {
                patterns.append(Pattern(chars: currentChars))
                currentChars = []
            } else {
                currentChars.append(Array(line))
            }
        }
        self.patterns = patterns
    }

    private func summary(tolerance: Int) -> Int {
        patterns.reduce(0) { acc, pattern in
            if let (index, row) = pattern.findMirror(tolerance: tolerance) {
                return acc + (row ? (index + 1) * 100 : (index + 1))
            }
            return acc
        }
    }

    func part1() {
        print(summary(tolerance: 0))
    }

    func part2() {
        print(summary(tolerance: 1))
    }
}
