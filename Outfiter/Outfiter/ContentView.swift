//
//  ContentView.swift
//  Outfiter
//
//  Created by Andres Diaz  on 22/08/23.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject var viewModel = PostViewModel()
    @State private var showPostDataInput = false
    @State private var name = ""
    @State private var selectedCategory = "64ca77d45cf35ef21b7ece5a"
    @State private var selectedColor = "64ca772f5cf35ef21b7ece41"
    @State private var creatorOutfits = false
    @State private var showOutfits = false
    @State private var selectedClothingIDs: [String] = []
    @State private var outfitName = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    List {
                        ForEach(viewModel.datosModelo) { clothing in
                            NavigationLink(destination: ClothingDetailView(clothing: clothing, viewModel: viewModel)) {
                                HStack {
                                    Text(clothing.name ?? "Nil")
                                    Spacer()
                                }
                            }
                        }

                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deletePost(at: index)
                            }
                        }
                    }
                    .task {
                        await viewModel.getPosts()
                    }
                    .navigationBarTitle("Closet")
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showPostDataInput.toggle()
                        }) {
                            Image(systemName: "plus")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding()
                                .background(.blue)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding()
                    }
                }
                .padding(.trailing, 16)
            }
            .navigationBarItems(leading:
                                    Button(action: {
                                        creatorOutfits.toggle()
                                    }) {
                                        HStack{
                                            Image(systemName: "person.and.background.dotted")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                            Text("Dressing Room").foregroundColor(.blue)
                                        }
                                    },
                                trailing: Button(action: {
                                    showOutfits.toggle()
                                }) {
                                    HStack{
                                        Image(systemName: "star.circle")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                        Text("Outfits").foregroundColor(.blue)
                                    }
                                }
            )
        }
        .sheet(isPresented: $showPostDataInput) {
            StorageView(name: $name, selectedCategory: $selectedCategory, selectedColor: $selectedColor)
                .onDisappear {
                    Task {
                        await viewModel.getPosts()
                    }
                }
        }
        .sheet(isPresented: $creatorOutfits) {
            CreateOutfitView(selectedClothingIDs: $selectedClothingIDs, outfitName: $outfitName, viewModel: viewModel, outfits: viewModel.datosModelo)
        }
        .sheet(isPresented: $showOutfits) {
            ViewerOutfits()
        }
    }
}

class NetworkingProvider: ObservableObject {
    func buscarData() async -> [Clothes]? {
        guard let url = URL(string: "https://backend-ot4e.onrender.com/api/clothings") else {
            print("Url invalida")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Clothes].self, from: data) {
                return decodedResponse
            }
        }
        catch {
            print("Ops!")
        }
      
        return nil
    }

    func deletePost(postID: String) async -> String? {
        guard let url = URL(string: "https://backend-ot4e.onrender.com/api/clothings/\(postID)") else {
            print("URL inválida")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    return "Post eliminado"
                }
            }
        } catch {
            print("Error al eliminar el post: \(error)")
        }

        return nil
    }
}

class NetworkingProviderPOST: ObservableObject {
    func enviarPost(body: [String: Any]) async -> String? {
        guard let url = URL(string: "https://backend-ot4e.onrender.com/api/clothings/") else {
            print("URL inválida")
            return nil
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let (data, _) = try await URLSession.shared.data(for: request)
            if let responseMessage = String(data: data, encoding: .utf8) {
                return responseMessage
            }
        } catch {
            print("Error al enviar POST: \(error)")
        }
        
        return nil
    }
    
    func deletePost(postID: String) async -> String? {
        guard let url = URL(string: "https://backend-ot4e.onrender.com/api/clothings/\(postID)") else {
            print("URL inválida")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    return "Post eliminado"
                }
            }
        } catch {
            print("Error al eliminar el post: \(error)")
        }

        return nil
    }
}

class NetworkingProviderOutfit: ObservableObject {
    func enviarPost(body: [String: Any]) async -> String? {
        guard let url = URL(string: "https://backend-ot4e.onrender.com/api/outfits/") else {
            print("URL inválida")
            return nil
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let (data, _) = try await URLSession.shared.data(for: request)
            if let responseMessage = String(data: data, encoding: .utf8) {
                return responseMessage
            }
        } catch {
            print("Error al enviar POST: \(error)")
        }
        
        return nil
    }
    
    func deletePost(postID: String) async -> String? {
        guard let url = URL(string: "https://backend-ot4e.onrender.com/api/clothings/\(postID)") else {
            print("URL inválida")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    return "Post eliminado"
                }
            }
        } catch {
            print("Error al eliminar el post: \(error)")
        }

        return nil
    }
}
