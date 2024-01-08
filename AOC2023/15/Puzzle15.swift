fileprivate enum Op {
    case remove, insert(Int)
}

fileprivate struct Step {
    let label: String
    let boxNumber: Int
    let operation: Op

    init(_ str: String) {
        let split = str.components(separatedBy: "=")
        if split.count > 1 {
            label = split[0]
            operation = .insert(Int(split[1])!)
        } else {
            label = String(str.dropLast())
            operation = .remove
        }
        boxNumber = Self.hash(label)
    }

    static func hash(_ str: String) -> Int {
        str.reduce(into: 0) { acc, char in
            acc += Int(char.asciiValue!)
            acc *= 17
            acc %= 256
        }
    }
}

struct Puzzle15: Puzzle {
    private let steps = InputFileReader.read("Input15")[0].components(separatedBy: ",")

    func part1() {
        print(steps.reduce(0) { $0 + Step.hash($1) })
    }

    func part2() {
        var boxes = [Int: [(label: String, focal: Int)]]()
        steps.forEach { str in
            let step = Step(str)
            switch step.operation {
            case .remove:
                if var lenses = boxes[step.boxNumber] {
                    lenses.removeAll { $0.0 == step.label }
                    boxes[step.boxNumber] = lenses
                }
            case .insert(let focalLength):
                if var lenses = boxes[step.boxNumber] {
                    if let existingIndex = lenses.firstIndex(where: { $0.0 == step.label }) {
                        lenses.remove(at: existingIndex)
                        lenses.insert((step.label, focalLength), at: existingIndex)
                    } else {
                        lenses.append((step.label, focalLength))
                    }
                    boxes[step.boxNumber] = lenses
                } else {
                    boxes[step.boxNumber] = [(step.label, focalLength)]
                }
            }
        }
        print(focusingPower(boxes))
    }

    private func focusingPower(_ boxes: [Int: [(label: String, focal: Int)]]) -> Int {
        let reshaped = boxes.flatMap { (key: Int, value: [(label: String, focal: Int)]) in
            value.enumerated().map { (index, element) in
                (element.label, element.focal, key + 1, index + 1)
            }
        }
        return reshaped.reduce(0) { acc, element in
            let (_, focalLength, boxNumber, slotNumber) = element
            return acc + (boxNumber * slotNumber * focalLength)
        }
    }
}
