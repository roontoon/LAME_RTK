//
//  JoyStickView.swift
//  LAME_RTK
//
//  Created by Roontoon on 9/11/23.
//
import SwiftUI

struct JoyStickView: View {
    @State private var blackCirclePosition: CGPoint? = nil
    @State private var speed: Double = 0
    @State private var direction: Double = 0
    
    // Reduce the size of the interface by 25%
    private let outerCircleRadius: CGFloat = (UIScreen.main.bounds.width * 2/3 / 2) * 0.75
    private var innerCircleRadius: CGFloat { outerCircleRadius * 0.25 }
    
    var body: some View {
        let blackCircleDiameter: CGFloat = innerCircleRadius * 2

        GeometryReader { geometry in
            let centerPoint = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                VStack {
                    Text("Speed: \(speed, specifier: "%.2f")")
                        .font(.title)
                    Text("Direction: \(direction, specifier: "%.2f")°")
                        .font(.title)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 4)
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                        .frame(width: outerCircleRadius * 2, height: outerCircleRadius * 2)

                    Circle()
                        .stroke(lineWidth: 2)
                        .frame(width: innerCircleRadius * 2, height: innerCircleRadius * 2)

                    if let blackCirclePosition = blackCirclePosition {
                        Sector(center: centerPoint, endPoint: blackCirclePosition, startAngle: CGFloat(direction - 135), endAngle: CGFloat(direction - 45))
                            .fill(RadialGradient(gradient: Gradient(colors: [Color.green, Color.red]), center: .center, startRadius: innerCircleRadius, endRadius: sqrt(pow(blackCirclePosition.x - centerPoint.x, 2) + pow(blackCirclePosition.y - centerPoint.y, 2))))
                    }
                    
                    Circle()
                        .fill()
                        .frame(width: blackCircleDiameter, height: blackCircleDiameter)
                        .position(blackCirclePosition ?? centerPoint)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let delta = CGPoint(x: value.location.x - centerPoint.x, y: value.location.y - centerPoint.y)
                            let distance = sqrt(pow(delta.x, 2) + pow(delta.y, 2))
                            let angle = atan2(delta.y, delta.x)

                            var angleInDegrees = Double(angle) * 180 / Double.pi
                            angleInDegrees = (angleInDegrees + 360).truncatingRemainder(dividingBy: 360)
                            direction = (angleInDegrees + 90).truncatingRemainder(dividingBy: 360)

                            speed = min(Double(distance / outerCircleRadius) * 100, 100)
                            
                            if distance > outerCircleRadius {
                                let boundedX = cos(angle) * outerCircleRadius + centerPoint.x
                                let boundedY = sin(angle) * outerCircleRadius + centerPoint.y
                                blackCirclePosition = CGPoint(x: boundedX, y: boundedY)
                            } else {
                                blackCirclePosition = value.location
                            }
                        }
                        .onEnded { _ in
                            blackCirclePosition = centerPoint
                            speed = 0
                            direction = 0
                        }
                )
                .onAppear {
                    blackCirclePosition = centerPoint
                }
            }
        }
    }
}

struct Sector: Shape {
    var center: CGPoint
    var endPoint: CGPoint
    var startAngle: CGFloat
    var endAngle: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: center)
        path.addArc(center: center, radius: sqrt(pow(endPoint.x - center.x, 2) + pow(endPoint.y - center.y, 2)), startAngle: .degrees(Double(startAngle)), endAngle: .degrees(Double(endAngle)), clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct JoyStickView_Previews: PreviewProvider {
    static var previews: some View {
        JoyStickView()
    }
}
