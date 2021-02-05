//
//  ContentView.swift
//  JSONBindableObjectSwiftUI
//
//  Created by student on 2/4/21.
//

import SwiftUI
import Combine

struct Course: Decodable{
    let name, imageUrl: String
}

struct Todo: Codable, Identifiable {
    public var id: Int
    public var title: String
    public var completed: Bool
}

class NetworkManager: ObservableObject {
  // 1.
  @Published var courses = [Course]()
     
    init() {
        let url = URL(string: "https://api.letsbuildthatapp.com/jsondecodable/courses")!
        // 2.
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let todoData = data {
                    // 3.
                    let decodedData = try JSONDecoder().decode([Course].self, from: todoData)
                    DispatchQueue.main.async {
                        self.courses = decodedData
                    }
                } else {
                    print("No data")
                }
            } catch {
                print("Error")
            }
            print(self.courses.count)
        }.resume()
    }
}

struct ContentView: View {
    
    @ObservedObject var nManager = NetworkManager()
    var body: some View {
        NavigationView {
            List {
                ForEach(nManager.courses, id: \.name){course in
                    CourseRowView(course: course)
                }
            }.navigationBarTitle(Text("Courses"))
        }
    }
}

struct CourseRowView: View {
    let course: Course
    var body: some View {
        VStack (alignment: .leading){
            RemoteImage(url: course.imageUrl)
                .aspectRatio(contentMode: .fit)
                .padding(.leading, -20)
                .padding(.trailing, -20)
            Text(course.name)
            
        }
    }
}

struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }

    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading

        init(url: String) {
            guard let parsedURL = URL(string: url) else {
                fatalError("Invalid URL: \(url)")
            }

            URLSession.shared.dataTask(with: parsedURL) { data, response, error in
                if let data = data, data.count > 0 {
                    self.data = data
                    self.state = .success
                } else {
                    self.state = .failure
                }

                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }.resume()
        }
    }

    @StateObject private var loader: Loader
    var loading: Image
    var failure: Image

    var body: some View {
        selectImage()
            .resizable()
    }

    init(url: String, loading: Image = Image(systemName: "photo"), failure: Image = Image(systemName: "multiply.circle")) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.loading = loading
        self.failure = failure
    }

    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            if let image = UIImage(data: loader.data) {
                return Image(uiImage: image)
            } else {
                return failure
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
