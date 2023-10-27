//
//  FloatingMenu.swift
//  LAME_RTK
//
//  Created by Roontoon on 10/12/23.
//  Last Modified on: 10/23/23
//
//  Overview:
//  This SwiftUI View file defines the FloatingMenu view.
//  The FloatingMenu consists of a tab bar (FloatingTabbar) at the bottom and a main content area that changes based on the selected tab.
//
import SwiftUI

// MARK: - Main FloatingMenu View
/// Main view that hosts the content and the FloatingTabbar.
struct FloatingMenu: View {
    
    // MARK: - State Variables
    /// Represents the selected tab (0 = Home, 1 = Wishlist, 2 = Cart)
    @State var selected = 0
    
    // MARK: - View Body
    /// The body property defines the structure and content of the view.
    var body: some View {
        
        // Root ZStack to overlay content and tab bar
        ZStack(alignment: .bottom){
            
            // Content area VStack
            VStack{
                
                // Home Tab Content
                if self.selected == 0{
                    GeometryReader{_ in
                        VStack(spacing: 15){
                            /*
                            Spacer()  // Pushes the other content to the middle
                            // Home label
                            Text("Home")
                                .font(.title)
                                .foregroundColor(.white)
                            
                            // Home image
                            Image("1").resizable().frame(height: 100).cornerRadius(2)
                            
                            Spacer()  // Pushes the other content to the middle
                            */
                        }.padding()  // Padding around the VStack
                    }
                }
                
                // Wishlist Tab Content
                else if self.selected == 1{
                    GeometryReader{_ in
                        VStack(spacing: 15){
                            /*Spacer()
                            Text("Wishlist")
                                .font(.title)
                                .foregroundColor(.white)
                            Image("2").resizable().frame(height: 100)   //.cornerRadius(4)
                            Spacer()
                             */
                        }.padding()
                    }
                }
                
                // Cart Tab Content
                else{
                    GeometryReader{_ in
                        VStack(spacing: 15){
                            /*
                            Spacer()
                            Text("Cart")
                                .font(.title)
                                .foregroundColor(.white)
                            Image("3").resizable().frame(height: 100)//.cornerRadius(4)
                            Spacer()
                             */
                        }.padding()
                    }
                }
                
            }
            // Attach the FloatingTabbar
            FloatingTabbar(selected: self.$selected)
        }.background(Color.gray)
    }
}

// MARK: - FloatingMenu Preview
/// Provides a preview of the FloatingMenu view.
struct FloatingMenu_Previews: PreviewProvider {
    static var previews: some View {
        FloatingMenu()
    }
}

// MARK: - FloatingTabbar View
/// A custom tab bar that floats above the main content.
struct FloatingTabbar : View {
    
    // MARK: - Properties
    /// A binding to the selected tab index from the parent view.
    @Binding var selected : Int  // Input: Selected tab index (binding)
    
    /// Controls the state of the tab bar (expanded or not).
    @State var expand = false
    
    // MARK: - View Body
    /// Defines the content and layout of the FloatingTabbar.
    var body : some View {  // Returns: some View
        
        // Root HStack
        HStack{
            // Creates a spacer that pushes content to the right
            Spacer(minLength: 0)
            
            // Inner HStack for the tab buttons
            HStack{
                
                // Dynamic content based on the expand state
                if !self.expand {
                    
                    // Expand button: Toggles the expand state
                    Button(action: {
                        self.expand.toggle()  // Toggle expand state
                    }) {
                        Image(systemName: "map").foregroundColor(.green).padding(2)
                    }
                }
                
                else {
                    // ******** add picker here.
                    // Home Tab Button
                    Button(action: {
                        self.selected = 0  // Set selected to Home
                    }) {
                        Image(systemName: "location").foregroundColor(self.selected == 0 ? .green : .gray).padding(.horizontal)
                    }
                    
                    // Spacer between buttons
                    //Spacer(minLength: 15)
                    
                    // Wishlist Tab Button
                    Button(action: {
                        self.selected = 1  // Set selected to Wishlist
                    }) {
                        Image(systemName: "mappin").foregroundColor(self.selected == 1 ? .green : .gray).padding(.horizontal)
                    }
                    
                    // Spacer between buttons
                    Spacer(minLength: 40)
                    
                    // Cart Tab Button
                    Button(action: {
                        self.selected = 2  // Set selected to Cart
                    }) {
                        Image(systemName: "plus.square").foregroundColor(self.selected == 2 ? .red : .gray).padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // When expanded, show the close button
                    if self.expand {
                        
                        // Close Button: Toggles the expand state to false
                        Button(action: {
                            self.expand = false  // Close the tab bar
                        }) {
                            Image(systemName: "xmark").foregroundColor(.red)//.padding()
                            
                            // Spacer()
                        }.padding(2)
                    }
                    
                    
                }
            }
            .padding(.vertical, self.expand ? 8 : 8)  // Vertical padding based on expand state
            .padding(.horizontal, self.expand ? 45 : 2)  // Horizontal padding based on expand state
            .background(Color.white)  // Background color of the tab bar
            .cornerRadius(10)
            //.clipShape(Capsule())  // Rounded corners
            .padding(10)  // Padding around the tab bar
            
            // Long press gesture to toggle expand
            .onLongPressGesture {
                self.expand.toggle()  // Toggle expand state
            }
            
        }.animation(.interactiveSpring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.6))  // Animation for expand toggle
    }
}
