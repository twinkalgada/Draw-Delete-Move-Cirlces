//
//  ContentView.swift
//  DrawCircle
//
//  Created by Twinkal Gada on 10/22/21.
//

import SwiftUI

struct ContentView: View {
    @State var allCircles: [CirclesContainer] = []
    @State var currentDraggingId = UUID()
    @State private var color: Color = Color.black
    @State private var mode: String = "Draw"
    @State private var location: CGPoint = CGPoint(x: 50, y: 50)
    @GestureState private var startLocation: CGPoint? = nil
    @State private var timer: Timer?
    @State var lastDragPosition: DragGesture.Value?
    @State var isDragging = false
    @State var circleLocation = CGPoint.zero
    @State private var selected: [UUID] = []
    
    var body: some View {
        VStack {
            HStack {
                Text("Color selected:")
                Circle()
                    .fill(color)
                    .frame(width: 30, height: 30)
                Text("Mode selected: \(mode)")
            }
            
            ZStack {
                Color.white
                ForEach(0..<allCircles.count, id:\.self) {i in
                        Circle()
                        .fill(allCircles[i].colorVal)
                        .frame(width: allCircles[i].radius, height: allCircles[i].radius)
                        .position(x: self.selected.contains(allCircles[i].Uid) ? (self.isDragging ? self.circleLocation.x : allCircles[i].center.x) : allCircles[i].center.x, y: self.selected.contains(allCircles[i].Uid) ? (self.isDragging ? self.circleLocation.y : allCircles[i].center.y) : allCircles[i].center.y)
                        .simultaneousGesture(tapGesture)
                        .simultaneousGesture(moveGesture)
                }
            }
            .gesture(drawGesture)
            .frame(width: 370, height: 550)
            DrawingControls(color: $color, mode: $mode, isDragging: $isDragging, selected: $selected)
        }
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    
    func isLocationInCircle(circleContainer: CirclesContainer, currentLocation: CGPoint) -> Bool {
        let PointOfLocationFromCenterX = circleContainer.center.x - currentLocation.x
        let PointOfLocationFromCenterY = circleContainer.center.y - currentLocation.y
        let distFromLocationToCenter = PointOfLocationFromCenterX*PointOfLocationFromCenterX + PointOfLocationFromCenterY*PointOfLocationFromCenterY
        let radiusOfCircleSquared = circleContainer.radius*circleContainer.radius
        if distFromLocationToCenter <= radiusOfCircleSquared {
            return true
        }
        return false
    }
    
    var moveGesture: some Gesture {
        mode == "Move" ? DragGesture()
            .onChanged {
                value in
                    self.isDragging = true
                    self.lastDragPosition = value
               
                //Check if which circle is moved
                for j in 0..<allCircles.count {
                    let isLocationInCircle = isLocationInCircle(circleContainer: allCircles[j], currentLocation: value.startLocation)
                    if isLocationInCircle {
                        self.selected.append(allCircles[j].Uid)
                        self.circleLocation = allCircles[j].center
                    }
                }
                var newLocation = self.circleLocation
                    newLocation.x += value.translation.width
                    newLocation.y += value.translation.height
                    self.circleLocation = newLocation

            }.onEnded({ (value) in
                let timeDiff = value.time.timeIntervalSince(self.lastDragPosition!.time)
                self.timer?.invalidate()
                
                let xOff = value.translation.width
                let yOff = value.translation.height
                let dist = sqrt(xOff*xOff + yOff*yOff);
                
                let dx = xOff/dist
                let dy = yOff/dist
                let speed = dist*timeDiff
                var deltaX = speed*dx
                var deltaY = speed*dy
                self.timer = Timer.scheduledTimer(withTimeInterval: timeDiff, repeats: true){ t in
                    self.circleLocation.x += deltaX
                    self.circleLocation.y += deltaY
                    
                    //Handle bouncing at edges
                    if self.circleLocation.x > 370 || self.circleLocation.x < 0 {
                        deltaX -= deltaX * 0.1
                        deltaX = -1 * deltaX
                    }
                    if self.circleLocation.y > 550 || self.circleLocation.y < 0 {
                        deltaY -= deltaY * 0.1
                        deltaY = -1 * deltaY
                    }
                }
            }) : nil
    }
    
    var tapGesture: some Gesture {
        mode == "Delete" ? DragGesture(minimumDistance: 0)
            .onEnded({ (value) in
            var radiusOfSelectedCircle: CGFloat = 0.0
            var centerOfSelectedCircle = CGPoint.zero
            var sumOfradius: CGFloat
            var indexToDelete: [Int] = []
            
            for j in 0..<allCircles.count {
                let isLocationInCircle = isLocationInCircle(circleContainer: allCircles[j], currentLocation: value.location)
                if isLocationInCircle {
                    radiusOfSelectedCircle = allCircles[j].radius
                    centerOfSelectedCircle = allCircles[j].center
                }
            }
            for i in 0..<allCircles.count {
                let radiusOfOtherCircle = allCircles[i].radius
                sumOfradius = radiusOfSelectedCircle + radiusOfOtherCircle
                let distBetweenTwoPoints = distance(allCircles[i].center, centerOfSelectedCircle)
                if sumOfradius > distBetweenTwoPoints {
                    indexToDelete.append(i)
                }
            }
            
            indexToDelete.sorted(by: >).forEach({ allCircles.remove(at: $0) })
            }) : nil
    }
    
    var drawGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if mode == "Draw" {
                    let start = value.startLocation
                    let end = value.location
                    let radius = abs(start.x - end.x)
                    allCircles.removeAll { $0.Uid == currentDraggingId }
                    allCircles.append(.init(Uid: currentDraggingId, colorVal: color, center: start, radius: radius))
                    
                }
            }
            .onEnded { _ in
                if mode == "Draw" {
                    currentDraggingId = .init()
                }
                
            }
    }
}

class CirclesContainer: Identifiable, ObservableObject {
    @Published var Uid: UUID
    @Published var colorVal: Color
    @Published var center: CGPoint
    @Published var radius: CGFloat
    
    init(Uid: UUID, colorVal: Color, center: CGPoint, radius: CGFloat) {
        self.Uid = Uid
        self.colorVal = colorVal
        self.center = center
        self.radius = radius
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ColorEntry: View {
    let colorInfo: ColorInfo
    
    var body: some View {
        HStack {
            Circle()
                .fill(colorInfo.color)
                .frame(width: 40, height: 40)
                .padding(.all)
            Text(colorInfo.displayName)
        }
    }
}

struct ModeEntry: View {
    let modeInfo: ModeInfo
    
    var body: some View {
        HStack {
            Image(systemName: "pencil")
                        .clipShape(Circle())
                        .shadow(radius: 5)
            Text(modeInfo.displayName)
        }
    }
}

struct ColorPicker: View {
    @Binding var color: Color
    @Binding var colorPickerShown: Bool
    
    private let colors = ColorsProvider.supportedColors()
    
    var body: some View {
        List(colors) { colorInfo in
            ColorEntry(colorInfo: colorInfo).onTapGesture {
                self.color = colorInfo.color
                self.colorPickerShown = false
            }
        }
    }
}

struct ModePicker: View {
    @Binding var mode: String
    @Binding var modePickerShown: Bool
    @Binding var isDragging: Bool
    @Binding var selected: [UUID]
    
    private let modes = ModesProvider.supportedModes()
    
    var body: some View {
        List(modes) { modeInfo in
            ModeEntry(modeInfo: modeInfo).onTapGesture {
                self.mode = modeInfo.mode
                self.modePickerShown = false
                self.isDragging = false
                self.selected = []
                
            }
        }
    }
}

struct ColorInfo: Identifiable {
    let id: Int
    let displayName: String
    let color: Color
}

struct ModeInfo: Identifiable {
    let id: Int
    let displayName: String
    let mode: String
}

class ColorsProvider {
    
    static func supportedColors() -> [ColorInfo] {
        return [ColorInfo(id: 1, displayName: "Blue", color: Color.blue),
                ColorInfo(id: 2, displayName: "Red", color: Color.red),
                ColorInfo(id: 3, displayName: "Green", color: Color.green),
                ColorInfo(id: 4, displayName: "Black", color: Color.black)
                ]
    }
    
}

class ModesProvider {
    
    static func supportedModes() -> [ModeInfo] {
        return [ModeInfo(id: 1, displayName: "Draw", mode: "Draw"),
                ModeInfo(id: 2, displayName: "Move", mode: "Move"),
                ModeInfo(id: 3, displayName: "Delete", mode: "Delete"),
        ]
    }
    
}

struct DrawingControls: View {
    @Binding var color: Color
    @Binding var mode: String
    @Binding var isDragging: Bool
    @Binding var selected: [UUID]
    
    @State private var colorPickerShown = false
    @State private var modePickerShown = false
    
    
    private let spacing: CGFloat = 30
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: spacing) {
                    
                    Button(action: {
                        self.colorPickerShown = true
                    }){Text("Pick Color")
                            .frame(minWidth: 100,  maxWidth: 100, minHeight: 44)

                .font(Font.subheadline.weight(.bold))
                .background(Color.blue).opacity(0.8)
                .foregroundColor(Color.white)
                        .cornerRadius(12)}
                        Button(action: {
                            self.modePickerShown = true
                        }){Text("Pick Mode")
                                .frame(minWidth: 100,  maxWidth: 100, minHeight: 44)

                    .font(Font.subheadline.weight(.bold))
                    .background(Color.blue).opacity(0.8)
                    .foregroundColor(Color.white)
                            .cornerRadius(12)}
                    
                }.frame(alignment: .top)
                    .padding(.bottom, 50)
                
            
            }
            
        }
        .frame(height: 140)
        .sheet(isPresented: $colorPickerShown, onDismiss: {
            self.colorPickerShown = false
        }, content: { () -> ColorPicker in
            ColorPicker(color: self.$color, colorPickerShown: self.$colorPickerShown)
        })
        .sheet(isPresented: $modePickerShown, onDismiss: {
            self.modePickerShown = false
        }, content: { () -> ModePicker in
            ModePicker(mode: self.$mode, modePickerShown: self.$modePickerShown, isDragging: self.$isDragging, selected: self.$selected)
        })
    }
}
