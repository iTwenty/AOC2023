fileprivate enum PulseType: CustomStringConvertible {
    case hi, lo
    var description: String { self == .hi ? "hi" : "lo" }
}

fileprivate struct Pulse {
    let source: String
    let dest: String
    let type: PulseType
}

fileprivate protocol Module {
    var name: String { get }
    var outputs: [String] { get }
    mutating func process(_ pulse: Pulse) -> [Pulse]
}

fileprivate struct Untyped: Module {
    let name: String
    let outputs: [String]
    mutating func process(_ pulse: Pulse) -> [Pulse] { return [] }
}

fileprivate struct Broadcast: Module {
    let name: String
    let outputs: [String]

    mutating func process(_ pulse: Pulse) -> [Pulse] {
        outputs.map { Pulse(source: name, dest: $0, type: pulse.type) }
    }
}

fileprivate struct FlipFlop: Module {
    let name: String
    let outputs: [String]
    var on: Bool = false

    mutating func process(_ pulse: Pulse) -> [Pulse] {
        if case .hi = pulse.type { return [] }
        on.toggle()
        let type: PulseType = on ? .hi : .lo
        return outputs.map { Pulse(source: name, dest: $0, type: type) }
    }
}

fileprivate struct Conjuncton: Module {
    let name: String
    let outputs: [String]
    var memory = [String: PulseType]()

    mutating func setInitialMemory(_ inputs: [String]) {
        inputs.forEach { input in
            memory[input] = .lo
        }
    }

    mutating func process(_ pulse: Pulse) -> [Pulse] {
        memory[pulse.source] = pulse.type
        let allHi = memory.values.reduce(true) { $0 && ($1 == .hi) }
        let type: PulseType = allHi ? .lo : .hi
        return outputs.map { Pulse(source: name, dest: $0, type: type) }
    }
}

struct Puzzle20: Puzzle {
    private let connections: [Module]

    init() {
        // Parse each input line in it's own module. Conjunction module names are
        // maintained in separate set to be used for setting their initial memory
        var conjunctions = Set<String>()
        var connections: [Module] = InputFileReader.read("Input20").map { line in
            let split = line.components(separatedBy: " -> ")
            let (name, outputs) = (split[0], split[1].components(separatedBy: ", "))
            if name.first! == "%" {
                return FlipFlop(name: String(name.dropFirst()), outputs: outputs)
            } else if name.first! == "&" {
                let realName = String(name.dropFirst())
                conjunctions.insert(realName)
                return Conjuncton(name: realName, outputs: outputs)
            } else if name == "broadcaster" {
                return Broadcast(name: name, outputs: outputs)
            } else {
                return Untyped(name: name, outputs: outputs)
            }
        }

        // Collect all the inputs for conjunction modules in a dictionary
        var conjunctionInputs = [String: [String]]()
        for conjunction in conjunctions {
            for connection in connections where connection.name != conjunction {
                let inputs = connection.outputs.filter { $0 == conjunction }
                guard !inputs.isEmpty else { continue }
                var existing = conjunctionInputs[conjunction, default: []]
                existing.append(connection.name)
                conjunctionInputs[conjunction] = existing
            }
        }

        // Update conjunction modules to set their memory using inputs dict
        for index in connections.indices {
            if let inputs = conjunctionInputs[connections[index].name] {
                var module = connections[index] as! Conjuncton
                module.setInitialMemory(inputs)
                connections[index] = module
            }
        }
        self.connections = connections
    }

    private func pushButton(connections: inout [Module]) -> (Int, Int) {
        var pending = [Pulse(source: "button", dest: "broadcaster", type: .lo)]
        var (hiCount, loCount) = (0, 0)
        while let current = pending.first {
            pending.remove(at: 0)
            let index = connections.firstIndex { $0.name == current.dest }
            var destModule = index.map { connections[$0] } ?? Untyped(name: current.dest, outputs: [])
            let newPulses = destModule.process(current)
            if current.type == .hi {
                hiCount += 1
            } else {
                loCount += 1
            }
            if let index { connections[index] = destModule }
            for pulse in newPulses {
                pending.append(pulse)
            }
        }
        print()
        return (hiCount, loCount)
    }

    func part1() {
        var connections = connections
        var (totalHi, totalLo) = (0, 0)
        for _ in 0..<1000 {
            let (hi, lo) = pushButton(connections: &connections)
            totalHi += hi
            totalLo += lo
        }
        print(totalHi * totalLo)
    }

    func part2() {
        // wut? o_O
    }
}
