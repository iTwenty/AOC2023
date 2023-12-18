//
//  Puzzle02.swift
//  AOC2023
//
//  Created by Jaydeep Joshi on 15/12/23.
//

fileprivate struct CubeCount: CustomStringConvertible {
    let r, g, b: Int
    var description: String { "{\(r), \(g), \(b)}" }
}

fileprivate typealias Game = [CubeCount]

fileprivate enum Parser {
    // Ex - Game 88: 3 green, 6 red, 2 blue; 3 blue, 2 green, 6 red; 1 red, 11 blue, 2 green
    static func parseLine(_ line: String) -> (Int, Game) {
        let partial = line.components(separatedBy: ": ")
        let gameId = Int(partial.first!.dropFirst(5))!
        let game = Self.parseGame(partial.last!)
        return (gameId, game)
    }

    // Ex - 3 green, 6 red, 2 blue; 3 blue, 2 green, 6 red; 1 red, 11 blue, 2 green
    private static func parseGame(_ str: String) -> Game {
        let partial = str.components(separatedBy: "; ")
        var game = Game()
        for p in partial {
            game.append(Self.parseCubeCount(p))
        }
        return game
    }

    // Ex - 1 red, 11 blue
    private static func parseCubeCount(_ str: String) -> CubeCount {
        let counts = str.split(separator: ", ")
        var (r, g, b) = (0, 0, 0)
        for count in counts {
            let tmp = count.components(separatedBy: " ")
            let count = Int(tmp.first!)!
            let color = tmp.last!
            if color == "red" {
                r = count
            } else if color == "green" {
                g = count
            } else if color == "blue" {
                b = count
            } else {
                fatalError("Unknown color \(color)")
            }
        }
        return CubeCount(r: r, g: g, b: b)
    }
}

struct Puzzle02: Puzzle {
    private let games: [Int: Game]

    init() {
        var games = [Int: Game]()
        InputFileReader.read("Input02").forEach { string in
            let (gameId, game) = Parser.parseLine(string)
            games[gameId] = game
        }
        self.games = games
    }

    func part1() {
        let seed = CubeCount(r: 12, g: 13, b: 14)
        let idSum = games.reduce(0) { acc, entry in
            if entry.value.allSatisfy({ $0.r <= seed.r && $0.g <= seed.g && $0.b <= seed.b }) {
                return acc + entry.key
            }
            return acc
        }
        print(idSum)
    }

    func part2() {
        let powerSum = games.values.map { game in
            let maxr = game.max { $0.r < $1.r }!.r
            let maxg = game.max { $0.g < $1.g }!.g
            let maxb = game.max { $0.b < $1.b }!.b
            return maxr * maxg * maxb
        }.reduce(0, +)
        print(powerSum)
    }
}
