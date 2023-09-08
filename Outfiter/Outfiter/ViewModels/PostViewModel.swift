//
//  PostViewModel.swift
//  Outfiter
//
//  Created by Macky on 7/09/23.
//

import SwiftUI

final class PostViewModel: ObservableObject {
    @Published var datosModelo = [Clothes]()
    private var provider = NetworkingProvider()
    
    @MainActor func getPosts() async {
        self.datosModelo = await provider.buscarData() ?? []
    }
    
    func deletePost(at index: Int) {
        let outfitToDelete = datosModelo[index]
        
        Task {
            if let response = await provider.deletePost(postID: outfitToDelete.id ?? "") {
                if response == "Post eliminado" {
                    datosModelo.remove(at: index)
                }
            }
        }
    }
    
    func toggleSelection(for clothing: Clothes) {
        if let index = datosModelo.firstIndex(where: { $0.id == clothing.id }) {
            datosModelo[index].isSelected.toggle()
        }
    }
    
}
