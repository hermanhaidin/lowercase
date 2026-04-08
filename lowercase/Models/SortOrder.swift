import Foundation

struct SortOrder: Equatable {
    var criterion: SortCriterion = .name
    var ascending: Bool = true

    mutating func select(_ newCriterion: SortCriterion) {
        if criterion == newCriterion {
            ascending.toggle()
        } else {
            criterion = newCriterion
            ascending = newCriterion.defaultAscending
        }
    }
}
