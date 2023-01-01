//
//  Combine.swift
//  spacialMemoryTodo
//
//  Created by Kai Quan Tay on 1/1/23.
//

import Foundation
import Combine

extension ObservableObjectPublisher {
    /// Wrapper function for `sink` that puts a specified delay before running the closure
    /// - Parameters:
    ///   - onThread: The thread to run the closure on. Defaults to main.
    ///   - deadline: The deadline to run the code. Use `.now() + value` to delay by `value` seconds.
    ///   - receiveValue: The closure to call after the deadline
    /// - Returns: A cancellable, used to cancel the subscription
    func sink(onThread: DispatchQueue = .main,
              runAfter deadline: @escaping () -> DispatchTime,
              receiveValue: @escaping () -> Void) -> AnyCancellable {
        self.sink {
            DispatchQueue.main.asyncAfter(deadline: deadline()) {
                receiveValue()
            }
        }
    }
}
