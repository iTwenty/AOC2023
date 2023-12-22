//
//  Puzzle.swift
//  AOC2023
//
//  Created by Jaydeep Joshi on 15/12/23.
//

/// Base protocol for all puzzles
protocol Puzzle {
    func part1() async
    func part2() async
}

struct Point2D: Hashable {
    let x, y: Int
}
