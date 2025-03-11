//
//  MountainLoadingView.swift
//  NPSExplorer
//
//  Created by Stefan Cutovic on 3/10/25.
//

import SwiftUI

struct MountainLoadingView: View {
    let text: String
    var minimumDuration: TimeInterval = 5.0
    var onComplete: (() -> Void)?
    
    @State private var mountainHeight1: CGFloat = 0
    @State private var mountainHeight2: CGFloat = 0
    @State private var mountainHeight3: CGFloat = 0
    @State private var showTrees: Bool = false
    @State private var showText = false
    @State private var sunOpacity: Double = 0
    @State private var rayRotation: Double = 0
    @State private var showView = true
    
    // Color for ice peaks - almost white but with a hint of gray
    let icePeakColor = Color(red: 0.95, green: 0.95, blue: 0.96)
    
    // Calculate where mountains begin (at their maximum heights)
    var mountain1Base: CGFloat { 90 }
    var mountain2Base: CGFloat { 90 }
    var mountain3Base: CGFloat { 90 }
    
    var body: some View {
        VStack(spacing: 24) {
            // Mountain range animation
            ZStack {
                // Mountain 1 (left)
                MountainPeak()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.gray.opacity(0.6)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 120, height: mountainHeight1)
                    .offset(x: -65, y: 90 - mountainHeight1/2)
                
                // Ice cap on mountain 1
                RuggedIceCap()
                    .fill(icePeakColor)
                    .frame(width: 25, height: 20)
                    .offset(x: -65, y: 90 - mountainHeight1 + 10)
                    .opacity(mountainHeight1 > 0 ? 1 : 0)
                
                // Mountain 2 (middle/tallest)
                MountainPeak()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.9), Color.gray.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 160, height: mountainHeight2)
                    .offset(y: 90 - mountainHeight2/2)
                
                // Ice cap on mountain 2
                RuggedIceCap()
                    .fill(icePeakColor)
                    .frame(width: 35, height: 30)
                    .offset(y: 90 - mountainHeight2 + 15)
                    .opacity(mountainHeight2 > 0 ? 1 : 0)
                
                // Mountain 3 (right)
                MountainPeak()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.5)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 110, height: mountainHeight3)
                    .offset(x: 70, y: 90 - mountainHeight3/2)
                
                // Ice cap on mountain 3
                RuggedIceCap()
                    .fill(icePeakColor)
                    .frame(width: 25, height: 18)
                    .offset(x: 70, y: 90 - mountainHeight3 + 9)
                    .opacity(mountainHeight3 > 0 ? 1 : 0)
                
                // Sun with rotating rays
                ZStack {
                    // Main sun
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 40, height: 40)
                    
                    // Sun rays
                    ForEach(0..<8) { i in
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: 5, height: 15)
                            .offset(y: -22)
                            .rotationEffect(.degrees(Double(i) * 45 + rayRotation))
                    }
                }
                .opacity(sunOpacity)
                .offset(x: -75, y: -55)
                
                // Trees - fewer in number and more varied in size and position
                // All positioned below the mountains' base level
                Group {
                    // Background trees (smallest, appear farther away)
                    
                    // Far background tree - right side
                    SimpleTree(
                        height: 30,
                        width: 18,
                        trunkHeight: 12,
                        trunkWidth: 2
                    )
                    .offset(x: 80, y: mountain3Base)
                    .opacity(showTrees ? 1 : 0)
                    
                    // Far background tree - middle
                    SimpleTree(
                        height: 26,
                        width: 16,
                        trunkHeight: 10,
                        trunkWidth: 2
                    )
                    .offset(x: 30, y: mountain2Base)
                    .opacity(showTrees ? 1 : 0)
                    
                    // Far background tree - left
                    SimpleTree(
                        height: 28,
                        width: 17,
                        trunkHeight: 11,
                        trunkWidth: 2
                    )
                    .offset(x: -90, y: mountain1Base)
                    .opacity(showTrees ? 1 : 0)
                }
                
                // Midground trees (medium sized)
                Group {
                    // Mid-sized tree - right side
                    SimpleTree(
                        height: 42,
                        width: 26,
                        trunkHeight: 16,
                        trunkWidth: 3
                    )
                    .offset(x: 50, y: mountain2Base)
                    .opacity(showTrees ? 1 : 0)
                    
                    // Mid-sized tree - center
                    SimpleTree(
                        height: 40,
                        width: 25,
                        trunkHeight: 16,
                        trunkWidth: 3
                    )
                    .offset(x: -10, y: mountain2Base)
                    .opacity(showTrees ? 1 : 0)
                    
                    // Mid-sized tree - left center
                    SimpleTree(
                        height: 38,
                        width: 24,
                        trunkHeight: 15,
                        trunkWidth: 3
                    )
                    .offset(x: -60, y: mountain1Base + 3)
                    .opacity(showTrees ? 1 : 0)
                }
                
                // Foreground trees (largest, appear closest)
                Group {
                    // Large tree - right foreground
                    SimpleTree(
                        height: 60,
                        width: 35,
                        trunkHeight: 20,
                        trunkWidth: 4
                    )
                    .offset(x: 20, y: mountain2Base + 35)
                    .opacity(showTrees ? 1 : 0)
                    
                    // Large tree - left foreground
                    SimpleTree(
                        height: 65,
                        width: 38,
                        trunkHeight: 22,
                        trunkWidth: 4
                    )
                    .offset(x: -40, y: mountain1Base + 32)
                    .opacity(showTrees ? 1 : 0)
                }
            }
            .frame(width: 250, height: 180)
            
            // Loading text
            Text(text)
                .foregroundColor(.white)
                .font(.headline)
                .opacity(showText ? 1 : 0)
        }
        .onAppear {
            // Animation sequence
            startAnimation()
        }
        .opacity(showView ? 1 : 0)
    }
    
    func startAnimation() {
        // Mountain animations
        withAnimation(.easeInOut(duration: 1.2)) {
            mountainHeight1 = 100
        }
        
        withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
            mountainHeight2 = 140
        }
        
        withAnimation(.easeInOut(duration: 0.8).delay(0.6)) {
            mountainHeight3 = 80
        }
        
        // Trees appear after mountains
        withAnimation(.easeIn(duration: 1.0).delay(1.0)) {
            showTrees = true
        }
        
        // Sun appears after mountains
        withAnimation(.easeIn(duration: 0.8).delay(1.5)) {
            sunOpacity = 1.0
        }
        
        // Rays rotating animation
        withAnimation(
            .linear(duration: 4.0)
            .delay(1.8)
            .repeatForever(autoreverses: false)
        ) {
            rayRotation = 360
        }
        
        // Text fades in
        withAnimation(.easeIn.delay(1.2)) {
            showText = true
        }
    }
    
    func hide() {
        withAnimation(.easeOut(duration: 0.5)) {
            showView = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onComplete?()
        }
    }
}

// Mountain peak shape
struct MountainPeak: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Rugged ice cap shape with zigzag bottom
struct RuggedIceCap: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Pointy top
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        
        // Right side
        path.addLine(to: CGPoint(x: rect.maxX - width * 0.1, y: rect.minY + height * 0.6))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        // Zigzag bottom
        let segments = 6
        let segmentWidth = width / CGFloat(segments)
        
        var currentX = rect.maxX
        var isUp = true
        
        for _ in 0..<segments {
            let nextX = currentX - segmentWidth
            let offsetY: CGFloat = isUp ? -height * 0.15 : 0
            
            path.addLine(to: CGPoint(x: nextX, y: rect.maxY + offsetY))
            
            currentX = nextX
            isUp.toggle()
        }
        
        // Left side
        path.addLine(to: CGPoint(x: rect.minX + width * 0.1, y: rect.minY + height * 0.6))
        
        // Back to top
        path.closeSubpath()
        
        return path
    }
}

// Simplified single-triangle tree
struct SimpleTree: View {
    var height: CGFloat
    var width: CGFloat
    var trunkHeight: CGFloat
    var trunkWidth: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // Single triangle for foliage - simpler and cleaner
            Triangle()
                .fill(Color.green)
                .frame(width: width, height: height)
            
            // Tree trunk
            Rectangle()
                .fill(Color(red: 0.76, green: 0.69, blue: 0.6))
                .frame(width: trunkWidth, height: trunkHeight)
        }
    }
}

// Simple triangle shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.8).ignoresSafeArea()
        MountainLoadingView(text: "Loading parks...")
    }
}
