struct Puzzle06: Puzzle {
    func part1() {
        let distanceRecords = [51: 222, 92: 2031, 68: 1126, 90: 1225]
        let waysToBeat = distanceRecords.map { (time, distanceRecord) in
            allDistancesGreaterThan(record: distanceRecord, possibleIn: time).count
        }
        print(waysToBeat.reduce(1, *))
    }

    func part2() {
        let waysToBeat = allDistancesGreaterThan(record: 222_2031_1126_1225, possibleIn: 51_92_68_90)
        print(waysToBeat.count)
    }

    private func allDistancesGreaterThan(record: Int, possibleIn time: Int) -> [Int] {
        (1..<time).compactMap { t in
            let distance = t * (time - t)
            return distance > record ? distance : nil
        }
    }
}
