//
//  ContentView.swift
//  JSONBindableObjectSwiftUI
//
//  Created by student on 2/4/21.
//

import SwiftUI
import Combine

struct Course: Decodable, Identifiable, Hashable {
    let id: Int
    let name, imageUrl: String
}

class NetworkManager: ObservableObject {
    var didChange = PassthroughSubject <NetworkManager, Never>()
    
    var courses = [Course](){
        didSet{
            didChange.send(self)
        }
    }
}

struct ContentView: View {
    
    let courses: [Course] = [.init(id: 0, name: "No Name", imageUrl: "no url"),
                             .init(id: 1, name: "No no Name", imageUrl: "no url")]
    
    var body: some View {
        NavigationView {
            List (courses){ course in
                Text(course.name)
            }.navigationBarTitle(Text("Courses"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
