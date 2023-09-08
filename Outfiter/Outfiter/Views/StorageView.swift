//
//  StorageView.swift
//  Outfiter
//
//  Created by Macky on 7/09/23.
//

import SwiftUI

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
