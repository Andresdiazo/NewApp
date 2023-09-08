//
//  ViewerOutfits.swift
//  Outfiter
//
//  Created by Macky on 7/09/23.
//

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
