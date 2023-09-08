//
//  OutfitViewModel.swift
//  Outfiter
//
//  Created by Macky on 7/09/23.
//

import SwiftUI

class OutfitViewModel: ObservableObject {
    @Published var outfits = [OutfitsSaved]()
    
    
    func getOutfitsFromAPI() {
        guard let url = URL(string: "https://backend-ot4e.onrender.com/api/outfits") else {
            print("URL inválida")
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decoder = JSONDecoder()
                let decodedOutfits = try decoder.decode([OutfitsSaved].self, from: data)
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

