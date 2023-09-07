//
//  ContentView.swift
//  Outfiter
//
//  Created by Andres Diaz  on 22/08/23.
//

import SwiftUI
import Foundation

struct StorageView: View {
    @Binding var name: String
    @Binding var selectedCategory: String
    @Binding var selectedColor: String
    @State private var postResponse: String?
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var postProvider = NetworkingProviderPOST()
    @StateObject var viewModel = PostViewModel()
    
    // Datos de categorías y colores
    let categories: [Category] = [
        Category(id: "64ca77c85cf35ef21b7ece56", category: "Accesorios", image_url: ""),
        Category(id: "64ca77ce5cf35ef21b7ece58", category: "Camisas", image_url: ""),
        Category(id: "64ca77d45cf35ef21b7ece5a", category: "Pantalones", image_url: ""),
        Category(id: "64ca77d95cf35ef21b7ece5c", category: "Zapatos", image_url: "")
    ]
    
    let colors: [Color] = [
        Color(id: "64ca77265cf35ef21b7ece3f", color: "Rojo"),
        Color(id: "64ca772f5cf35ef21b7ece41", color: "Amarillo"),
        Color(id: "64ca77335cf35ef21b7ece43", color: "Azul"),
        Color(id: "64ca773b5cf35ef21b7ece45", color: "Violeta"),
    ]
    
    var body: some View {
        VStack {
            Picker("Categoría", selection: $selectedCategory) {
                ForEach(categories, id: \.id) { category in
                    Text(category.category ?? "Desconocido").tag(category.id ?? "")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Picker("Color", selection: $selectedColor) {
                ForEach(colors, id: \.id) { color in
                    Text(color.color ?? "Desconocido").tag(color.id ?? "")
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            TextField("Nombre", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                enviarPOST()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Añadir Prenda")
                    .frame(width: 200, height: 40)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Text("Respuesta POST: \(postResponse ?? "")")
        }
    }
    
    private func enviarPOST() {
        
        
        let body: [String: Any] = [
            "name": name,
            "category": selectedCategory,
            "color": selectedColor
        ]
        
        Task {
            if let response = await postProvider.enviarPost(body: body) {
                postResponse = response
                await viewModel.getPosts()
                print("Nombre de la prenda: \(name)")
                            print("Categoría de la prenda: \(selectedCategory)")
                            print("Color de la prenda: \(selectedColor)")
            } else {
                postResponse = "Error al enviar POST"
            }
        }
    }
}

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
                        ForEach(viewModel.datosModelo) { post in
                            HStack {
                                Text(post.name ?? "Nil")
//                                Text(post.color?.color ?? "Nil")

                                Spacer()
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
    func buscarData() async -> [Prendas]? {
        guard let url = URL(string: "https://backend-ot4e.onrender.com/api/clothings") else {
            print("Url invalida")
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Prendas].self, from: data) {
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

struct Prendas: Codable, Identifiable {
    let id: String?
    let name: String?
    let category: Category?
    let color: Color?
    let imgURL: String?
    var clothings: [Clothing]? // Agrega esta propiedad

    enum CodingKeys: String, CodingKey {
        case id, name, imgURL
        case category = "category"
        case color = "color"
    }
}

struct Category: Codable {
    let id: String?
    let category: String?
    let image_url: String?
}

struct Color: Codable {
    let id: String?
    let color: String?
}

struct Clothing: Codable, Identifiable { // Define la estructura Clothing para representar las prendas
    let id: String?
    let name: String?
    let category: Category?
    let color: Color?
    let imageUrl: String?
}

final class PostViewModel: ObservableObject {
    @Published var datosModelo = [Prendas]()
    private var provider = NetworkingProvider()

    @MainActor func getPosts() async {
        self.datosModelo = await provider.buscarData() ?? []
    }

    func deletePost(at index: Int) {
        let outfitToDelete = datosModelo[index]
        
        Task {
            if let response = await provider.deletePost(postID: outfitToDelete.id ?? "") {
                if response == "Post eliminado" {
                    // Elimina el post eliminado de los datos locales
                    datosModelo.remove(at: index)
                }
            }
        }
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

struct FloatingButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding()
                .background(.cyan)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
        .padding()
        .background(.green)
        .position(x: UIScreen.main.bounds.width - 40, y: UIScreen.main.bounds.height - 80)
    }
}

struct CreateOutfitView: View {
    @Binding var selectedClothingIDs: [String]
    @Binding var outfitName: String
    @State private var outfitResponse: String?
    @ObservedObject var viewModel: PostViewModel
    let outfits: [Prendas]
    @StateObject var postProvider = NetworkingProviderOutfit()
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        VStack {
            Text("Dressing Room")
                .font(.title)
                .bold()
                .padding()
                
            Text("Selecciona las prendas para tu outfit:")
                .font(.title)
                .padding()
            
            List {
                ForEach(viewModel.datosModelo) { clothing in
                    let isSelected = selectedClothingIDs.contains(clothing.id ?? "")
                    HStack {
                        Text(clothing.name ?? "Nil")
//                        Text(clothing.color?.color ?? "Nil")
                        Spacer()
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .green : .gray)
                    }
                    .onTapGesture {
                        if isSelected {
                            // Si ya está seleccionada, deselecciónala
                            selectedClothingIDs.removeAll { $0 == clothing.id }
                        } else {
                            // Si no está seleccionada, selecciónala
                            selectedClothingIDs.append(clothing.id ?? "")
                        }
                    }
                }
            }
            
            TextField("Nombre del outfit", text: $outfitName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button(action: {
                enviarOutfit()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Crear Outfit")
                    .frame(width: 200, height: 40)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Text("Respuesta del servidor: \(outfitResponse ?? "")")
        
        }
    }
    private func enviarOutfit() {
        // Verifica que haya al menos una prenda seleccionada y un nombre de outfit válido
        guard !selectedClothingIDs.isEmpty, !outfitName.isEmpty else {
            outfitResponse = "Debes seleccionar prendas y proporcionar un nombre."
            return
        }
        
        // Verifica que todos los IDs seleccionados sean válidos
        let invalidIDs = selectedClothingIDs.filter { id in
            return !viewModel.datosModelo.contains { clothing in
                return clothing.id == id
            }
        }
        
        
        if !invalidIDs.isEmpty {
            outfitResponse = "IDs de prendas inválidos: \(invalidIDs.joined(separator: ", "))"
            return
        }
        
        
        let selectedClothingDetails: [[String: Any]] = viewModel.datosModelo
                .filter { selectedClothingIDs.contains($0.id ?? "") }
                .map { clothing in
                    var clothingDetails = [String: Any]()
                    clothingDetails["id"] = clothing.id
                    clothingDetails["name"] = clothing.name
                    clothingDetails["category"] = clothing.category?.category
                    clothingDetails["color"] = clothing.color?.color
                    return clothingDetails
                }
        // Los IDs son válidos, procede con la creación del outfit
        let body: [String: Any] = [
            "name": outfitName,
            "clothings": selectedClothingIDs
        ]
        
        // Obtenemos los nombres de categorías y colores correspondientes a los IDs seleccionados
        let selectedCategoryNames = viewModel.datosModelo
            .filter { selectedClothingIDs.contains($0.id ?? "") }
            .compactMap { $0.category?.category }
        
        let selectedColorNames = viewModel.datosModelo
            .filter { selectedClothingIDs.contains($0.id ?? "") }
            .compactMap { $0.color?.color }
        let selectedClothingNames = viewModel.datosModelo
                .filter { selectedClothingIDs.contains($0.id ?? "") }
                .compactMap { $0.name }
        
        print("Nombre del Outfit: \(outfitName)")
        print("Nombres de las prendas seleccionadas: \(selectedClothingNames.joined(separator: ", "))")
        print("IDs seleccionados de prendas: \(selectedClothingIDs.joined(separator: ", "))")
        print("Categorías seleccionadas: \(selectedCategoryNames.joined(separator: ", "))")
        print("Colores seleccionados: \(selectedColorNames.joined(separator: ", "))")
        
        Task {
            if let response = await postProvider.enviarPost(body: body) {
                outfitResponse = response
                selectedClothingIDs.removeAll()
                outfitName = ""
                print("Respuesta del servidor: \(outfitResponse ?? "")")
            } else {
                outfitResponse = "Error al crear el outfit."
                print("Respuesta del servidor: \(outfitResponse ?? "")")
            }
        }
    }
}

import SwiftUI

struct ViewerOutfits: View {
    @StateObject var outfitViewModel = OutfitViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(outfitViewModel.outfits) { outfit in
                    NavigationLink(destination: OutfitDetailView(outfit: outfit)) {
                        Text(outfit.name )
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let outfitToDelete = outfitViewModel.outfits[index]
                        outfitViewModel.deleteOutfit(at: outfitToDelete.id )
                    }
                }
            }
            .navigationBarTitle("Lista de Outfits")
            .onAppear {
                outfitViewModel.getOutfitsFromAPI()
            }
        }
    }
}


struct OutfitDetailView: View {
    let outfit: OutfitsGuardados

    var body: some View {
        VStack {
            Text(outfit.name)
                .font(.title)

//            Text("Prendas en este outfit:")
//                .font(.headline)

            List(outfit.clothings) { clothing in
                HStack {
                    Text(clothing.name)
                    Spacer()
                    Text("Color: \(clothing.color.color)")
                    Text("Categoría: \(clothing.category.category)")
                }
            }
        }
        .padding()
//        .navigationBarTitle(outfit.name)
    }
}


class OutfitViewModel: ObservableObject {
    @Published var outfits = [OutfitsGuardados]()
    
    
    func getOutfitsFromAPI() {
        guard let url = URL(string: "https://backend-ot4e.onrender.com/api/outfits") else {
            print("URL inválida")
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                let decodedOutfits = try decoder.decode([OutfitsGuardados].self, from: data)
                DispatchQueue.main.async { [self] in
                    outfits = decodedOutfits
                }
            } catch {
                print("Error al obtener los outfits: \(error)")
            }
        }
    }

    
}


extension OutfitViewModel {
    func deleteOutfit(at outfitID: String) {
        Task {
            if let response = await deleteOutfitFromAPI(outfitID: outfitID) {
                if response == "Outfit eliminado" {
                    // Elimina el outfit eliminado de los datos locales
                    outfits.removeAll { $0.id == outfitID }
                }
            }
        }
    }
    
    private func deleteOutfitFromAPI(outfitID: String) async -> String? {
        guard let url = URL(string: "https://backend-ot4e.onrender.com/api/outfits/\(outfitID)") else {
            print("URL inválida")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    return "Outfit eliminado"
                }
            }
        } catch {
            print("Error al eliminar el outfit: \(error)")
        }

        return nil
    }
}

struct OutfitsGuardados: Codable, Identifiable {
    let name: String
    let clothings: [Clothing]
    let id: String
    
    struct Clothing: Codable, Identifiable {
        let name: String
        let color: Color
        let category: Category
        let id: String
        let image_url: String
    }
    
    struct Color: Codable {
        let color: String
        let id: String
    }
    
    struct Category: Codable {
        let category: String
        let id: String
    }
}
