//
//  ContentView.swift
//  Sandtrix
//
//  Created by akio0911 on 2024/08/16.
//

import SwiftUI

let width = 8
let height = 8

struct ContentView: View {
    @State private var box = Array(repeating: Array(repeating: "⬜️", count: width), count: height)
    @State private var eraseCount = 0

    var body: some View {
        VStack {
            Text("消去数: \(eraseCount)")
                .font(.headline)
                .padding()

            GridView(box: box)

            Button(action: {
                dropSand()
                checkAndRemoveConnectedClusters()
                applyGravity()
            }) {
                Text("次の粒子を落とす")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }

    func dropSand() {
        var x = width / 2
        var y = 0

        while y < height - 1 {
            if box[y + 1][x] == "⬜️" { // 下が空いているなら下に移動
                y += 1
            } else if x > 0 && box[y + 1][x - 1] == "⬜️" { // 左下が空いているなら左下に移動
                y += 1
                x -= 1
            } else if x < width - 1 && box[y + 1][x + 1] == "⬜️" { // 右下が空いているなら右下に移動
                y += 1
                x += 1
            } else {
                break // それ以外の場合は停止
            }
        }

        // 粒子を配置
        box[y][x] = ["🔴", "🔵"].randomElement()!
    }

    func dfs(x: Int, y: Int, color: String, visited: inout [[Bool]], cluster: inout [(Int, Int)]) {
        if x < 0 || x >= height || y < 0 || y >= width {
            return
        }
        if visited[x][y] || box[x][y] != color {
            return
        }

        visited[x][y] = true
        cluster.append((x, y))

        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        for (dx, dy) in directions {
            dfs(x: x + dx, y: y + dy, color: color, visited: &visited, cluster: &cluster)
        }
    }

    func checkAndRemoveConnectedClusters() {
        var visited = Array(repeating: Array(repeating: false, count: width), count: height)

        for i in 0..<height {
            if box[i][0] != "⬜️" && !visited[i][0] {
                var cluster = [(Int, Int)]()
                dfs(x: i, y: 0, color: box[i][0], visited: &visited, cluster: &cluster)

                let reachesRightSide = cluster.contains { $0.1 == width - 1 }
                if reachesRightSide {
                    print("消えた！")
                    for (x, y) in cluster {
                        box[x][y] = "⬜️" // 粒子を消去
                    }
                    eraseCount += 1
                }
            }
        }
    }

    func applyGravity() {
        for y in 0..<width {
            var stack = [String]()
            for x in 0..<height {
                if box[x][y] != "⬜️" {
                    stack.append(box[x][y])
                }
            }
            // 上から粒子を落とす
            for x in 0..<height {
                if x < stack.count {
                    box[height - 1 - x][y] = stack[stack.count - 1 - x]
                } else {
                    box[height - 1 - x][y] = "⬜️"
                }
            }
        }
    }
}

struct GridView: View {
    let box: [[String]]

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<height, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<width, id: \.self) { col in
                        Text(box[row][col])
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(4)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
