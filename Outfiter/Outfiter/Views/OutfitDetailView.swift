//
//  OutfitDetailView.swift
//  Outfiter
//
//  Created by Macky on 7/09/23.
//

import SwiftUI

struct OutfitDetailView: View {
    let outfit: OutfitsSaved
    
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
    }
}
