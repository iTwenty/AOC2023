//
//  main.swift
//  AOC2023
//
//  Created by Jaydeep Joshi on 15/12/23.
//

import Foundation

@main
struct Runner {
    static func main() async throws {
        let puzzle = Puzzle20()
        await puzzle.part1()
        await puzzle.part2()
    }
}
