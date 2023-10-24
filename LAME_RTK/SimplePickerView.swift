import SwiftUI

struct SimplePickerView: View {
    
    // MARK: - Properties and Variables
    /// Declare a state for managing the selected Map ID
    @State var selectedMapID: String = "DefaultID"
    
    /// Dummy map IDs for testing
    let mapIDs = ["Map1", "Map2", "Map3"]
    
    // MARK: - Body Definition
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                
                // Background color for testing
                Color.gray.opacity(0.3)
                
                // Floating Picker
                Picker("Select Map ID", selection: $selectedMapID) {
                    ForEach(mapIDs, id: \.self) { mapID in
                        Text(mapID)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.1)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
                .padding()
            }
        }
    }
}

struct SimplePickerView_Previews: PreviewProvider {
    static var previews: some View {
        SimplePickerView()
    }
}
