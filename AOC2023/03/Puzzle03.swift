import Foundation

struct Puzzle03: Puzzle {
    private let input = InputFileReader.read("Input03").map(Array.init)

    func part1() {
        var p1Sum = 0
        var p2Sum = 0
        for (y, line) in input.enumerated() {
            for (x, char) in line.enumerated() {
                guard isValidSymbol(char) else { continue }
                let adjacentNumbers = findAdjacentNumbers(x, y)
                p1Sum += adjacentNumbers.reduce(0, +)
                if char == "*" && adjacentNumbers.count == 2 {
                    p2Sum += adjacentNumbers.reduce(1, *)
                }
            }
        }
        print(p1Sum)
        print(p2Sum)
    }

    private func isValidSymbol(_ c: Character) -> Bool {
        c != "." && !c.isNumber
    }

    private func findAdjacentNumbers(_ x: Int, _ y: Int) -> some Collection<Int> {
        // Map key is start point of number. Map needed to ensure a number is included only once
        var adjacentNumbers = [Point2D: Int]()
        let adjacentIndexDiffs = [(-1,-1),(0,-1),(1,-1),(-1,0),(1,0),(-1,1),(0,1),(1,1)]
        for diff in adjacentIndexDiffs {
            let xPos = x + diff.0
            let yPos = y + diff.1
            if xPos < input[0].count, yPos < input.count, input[yPos][xPos].isNumber {
                let (start, num) = parseNumber(xPos, yPos)
                adjacentNumbers[start] = num
            }
        }
        return adjacentNumbers.values
    }

    // x and y can refer to position of any digit in the number.
    private func parseNumber(_ x: Int, _ y: Int) -> (Point2D, Int) {
        var startX = x - 1, endX = x + 1
        // Go back along x to find start index of number
        while startX > -1, input[y][startX].isNumber {
            startX -= 1
        }
        startX += 1
        // Go forward along x to find end index of number
        while endX < input[0].count, input[y][endX].isNumber {
            endX += 1
        }
        endX -= 1
        let num = Int(String(input[y][startX...endX]))!
        return (Point2D(x: startX, y: y), num)
    }

    func part2() { print("Done in part1()") }
}
