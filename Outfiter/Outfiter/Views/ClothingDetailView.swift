//
//  ClothingDetailView.swift
//  Outfiter
//
//  Created by Macky on 7/09/23.
//

import SwiftUI

struct ClothingDetailView: View {
    let clothing: Clothes
    @ObservedObject var viewModel: PostViewModel
    @StateObject var outfitViewModel = OutfitViewModel()
    
    var body: some View {
        VStack {
            Text("Detalles de la Prenda")
                .font(.title)
                .padding()
            
            Text("Nombre: \(clothing.name ?? "N/A")")
                .padding()
                        
            Text("Outfits relacionados:")
                .font(.headline)
                .padding(.top)
            
            List(outfitViewModel.outfits) { outfit in
                if outfit.clothings.contains(where: { $0.id == clothing.id }) {
                    NavigationLink(destination: OutfitDetailView(outfit: outfit)) {
                        Text(outfit.name)
                    }
                }
            }
        }
        .onAppear {
            outfitViewModel.getOutfitsFromAPI()
        }
    }
}
