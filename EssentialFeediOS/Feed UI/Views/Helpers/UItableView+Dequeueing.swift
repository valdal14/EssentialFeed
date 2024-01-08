//
//  UItableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Valerio D'ALESSIO on 5/1/24.
//

import UIKit

extension UITableView {
	func dequeueReusableCell<T: UITableViewCell>() -> T  {
		let idendifier = String(describing: T.self)
		return dequeueReusableCell(withIdentifier: idendifier) as! T
	}
}
