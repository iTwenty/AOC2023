struct RangeMap {
    let sources, destinations: [CountableRange<Int>]

    init(sources: [CountableRange<Int>], destinations: [CountableRange<Int>]) {
        let sorted = zip(sources, destinations).sorted { $0.0.lowerBound < $1.0.lowerBound }
        self.sources = sorted.map(\.0)
        self.destinations = sorted.map(\.1)
    }

    subscript(key: Int) -> Int {
        guard let sourceIndex = binarySearch(key: key) else { return key }
        let sourceRange = sources[sourceIndex]
        let destinationRange = destinations[sourceIndex]
        let diff = key - sourceRange.lowerBound
        return destinationRange.lowerBound + diff
    }

    private func binarySearch(key: Int) -> Int? {
        func recursive(_ key: Int, _ lo: Int, _ hi: Int) -> Int? {
            if lo > hi { return nil }
            let mid = (hi + lo) / 2
            let currentSourceRange = sources[mid]
            if currentSourceRange.contains(key) {
                return mid
            } else if currentSourceRange.upperBound <= key {
                return recursive(key, mid+1, hi)
            } else {
                return recursive(key, lo, mid-1)
            }
        }
        return recursive(key, sources.startIndex, sources.endIndex-1)
    }
}

struct Puzzle05: Puzzle {
    private let seeds: [Int]
    private let rangeMaps: [RangeMap]

    init() {
        let input = InputFileReader.read("Input05")
        var (sources, destinations) = ([CountableRange<Int>](), [CountableRange<Int>]())
        var seeds: [Int]?
        var rangeMaps = [RangeMap]()
        for line in input {
            if line.starts(with: "seeds:") {
                seeds = line.dropFirst(7).split(separator: " ").map { Int($0)! }
            } else if line.last == ":" {
                if !sources.isEmpty, !destinations.isEmpty {
                    rangeMaps.append(RangeMap(sources: sources, destinations: destinations))
                    sources.removeAll()
                    destinations.removeAll()
                }
            } else {
                let numbers = line.split(separator: " ").map { Int($0)! }
                sources.append(numbers[1]..<numbers[1]+numbers[2])
                destinations.append((numbers[0]..<numbers[0]+numbers[2]))
            }
        }
        rangeMaps.append(RangeMap(sources: sources, destinations: destinations))
        self.seeds = seeds!
        self.rangeMaps = rangeMaps
    }

    func part1() async {
        print(await findMin(seeds: seeds))
    }

    // WARNING : Slow and unoptimized. Needs a few hours give out the answer.
    func part2() async {
        var seedRanges = [CountableRange<Int>]()
        for (index, num) in seeds.enumerated() {
            if index % 2 != 0 {
                seedRanges.append(seeds[index-1]..<seeds[index-1]+num)
            }
        }
        let locations = await withTaskGroup(of: Int.self) { group in
            seedRanges.forEach { seedRange in
                group.addTask {
                    print("Group for seeds \(seedRange) started")
                    let min = await findMin(seeds: seedRange)
                    print("Group for seeds \(seedRange) ended with min location \(min)")
                    return min
                }
            }

            var locations = [Int]()
            for await g in group {
                locations.append(g)
            }
            return locations
        }
        print(locations.min()!)
    }

    private func findMin(seeds: some Collection<Int>) async -> Int {
        return seeds.map { seed in
            rangeMaps.reduce(seed) { acc, map in map[acc] }
        }.min()!
    }
}
