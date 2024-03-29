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

struct Point2D: Hashable, Comparable, CustomStringConvertible {
    let x, y: Int
    var description: String { "(\(x), \(y))" }

    static func + (lhs: Point2D, rhs: Point2D) -> Point2D {
        Point2D(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: Point2D, rhs: Point2D) -> Point2D {
        Point2D(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func < (lhs: Point2D, rhs: Point2D) -> Bool {
        if lhs.y == rhs.y {
            return lhs.x < rhs.x
        }
        return lhs.y < rhs.y
    }
}

/// Returns the Greatest Common Divisor of two numbers.
func gcd(_ x: Int, _ y: Int) -> Int {
    var a = 0
    var b = max(x, y)
    var r = min(x, y)

    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}


/// Returns the least common multiple of two numbers.
func lcm(_ x: Int, _ y: Int) -> Int {
    return x / gcd(x, y) * y
}
