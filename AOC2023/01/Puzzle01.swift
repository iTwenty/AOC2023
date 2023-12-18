struct Puzzle01: Puzzle {
    private let strings = InputFileReader.read("Input01")

    func part1() {
        let sum = strings.map { s in
            let numChars = s.filter(\.isNumber)
            return Int("\(numChars.first!)\(numChars.last!)")!
        }.reduce(0, +)
        print(sum)
    }

    func part2() {
        let digitMap = ["zero": "0", "one": "1", "two": "2", "three": "3", "four": "4",
                        "five": "5", "six": "6", "seven": "7", "eight": "8", "nine": "9"]
        let sum = strings.map { s in
            let charArray = Array(s)
            var numChars = ""
            for (index, c) in charArray.enumerated() {
                if c.isNumber {
                    numChars.append("\(c)")
                } else {
                    for spelling in digitMap.keys {
                        if charArray[index...].starts(with: spelling) {
                            numChars.append(digitMap[spelling]!)
                        }
                    }
                }
            }
            return Int("\(numChars.first!)\(numChars.last!)")!
        }.reduce(0, +)
        print(sum)
    }
}
