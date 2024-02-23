//
//  ContentView.swift
//  VisualTodo
//
//  Created by Jared Davidson on 2/23/24.
//

import SwiftUI
import Glur

struct TodoItem {
    let name: String
    let imageUrl: String
    var complete: Bool = false
}

struct ContentView: View {
    @State private var todoText = ""
    @State private var todoItems: [TodoItem] = []
    
    func fetchImageForTodo() {
        // Fetch image from Unsplash API based on todo text
        guard let url = URL(string: "https://api.unsplash.com/photos/random?query=\(todoText)&client_id=ri_RkWxwnhPidepEo1xWm_ZcoPA5YW6E_jE9OcNUMeo") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let todoImage = try? JSONDecoder().decode(TodoImage.self, from: data) {
                DispatchQueue.main.async {
                    let newTodoItem = TodoItem(name: self.todoText, imageUrl: todoImage.urls.regular)
                    self.todoItems.append(newTodoItem)
                    self.todoText = ""
                }
            } else {
                print("Error decoding image data")
            }
        }
        task.resume()
    }
    
    var body: some View {
        ScrollView {
            if todoItems.isEmpty {
                Text("Add a task")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(Array(zip(todoItems.indices, todoItems)), id: \.0) { index, todoItem in
                        ZStack {
                            Button {
                                todoItems[index].complete.toggle()
                            } label: {
                                ZStack {
                                    AsyncImage(url: URL(string: todoItem.imageUrl)) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .zIndex(0)
                                            .glur(radius: 5.0, // The total radius of the blur effect when fully applied.
                                                  offset: 0.7, // The distance from the view's edge to where the effect begins, relative to the view's size.
                                                  direction: .down // The direction in which the effect is applied.
                                            )
                                    } placeholder: {
                                        ProgressView()
                                            .zIndex(0)
                                    }
                                    
                                    VStack {
                                        Spacer()
                                        Text(todoItem.name)
                                            .font(.caption)
                                            .bold()
                                            .foregroundStyle(.white)
                                            .padding()
                                    }
                                    .zIndex(1)
                                    
                                    if todoItem.complete {
                                        Color.green.opacity(0.1)
                                            .zIndex(2)
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .zIndex(3)

                                        
                                    }
                                }
                                .frame(width: 160, height: 250)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.white.opacity(0.1))
        .overlay(
            HStack {
                TextField("Enter a todo", text: $todoText)
                    .foregroundColor(Color.black)
                    .padding()
                
                Button(action: {
                    self.fetchImageForTodo()
                }) {
                    Image(systemName: "arrow.up")
                        .frame(width: 40, height: 40, alignment: .center)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
                .padding(.horizontal)
                .frame(height: 60)
            .background(Color.white)
            .cornerRadius(50)
            .shadow(radius: 10)
            .padding()
            , alignment: .bottom
        )
    }
}

struct TodoImage: Codable {
    let urls: ImageUrls
}

struct ImageUrls: Codable {
    let regular: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Text {
    func getContrastText(backgroundColor: Color) -> some View {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        UIColor(backgroundColor).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  luminance < 0.6 ? self.foregroundColor(.white) : self.foregroundColor(.black)
    }
}
