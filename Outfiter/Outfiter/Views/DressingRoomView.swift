//
//  DressingRoomView.swift
//  Outfiter
//
//  Created by Macky on 7/09/23.
//

import SwiftUI

struct CreateOutfitView: View {
    @Binding var selectedClothingIDs: [String]
    @Binding var outfitName: String
    @State private var outfitResponse: String?
    @ObservedObject var viewModel: PostViewModel
    let outfits: [Clothes]
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
        guard !selectedClothingIDs.isEmpty, !outfitName.isEmpty else {
            outfitResponse = "Debes seleccionar prendas y proporcionar un nombre."
            return
        }
        
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
        
        let body: [String: Any] = [
            "name": outfitName,
            "clothings": selectedClothingIDs
        ]
        
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
