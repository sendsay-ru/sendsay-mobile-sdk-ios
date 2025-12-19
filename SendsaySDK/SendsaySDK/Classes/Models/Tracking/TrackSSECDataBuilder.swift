//
//  TrackSSECDataBuilder.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 05.09.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

// MARK: - Errors
enum TrackBuildError: Error, LocalizedError {
    case requiredFieldMissing(String)
    case invalidItems(String)

    var errorDescription: String? {
        switch self {
        case .requiredFieldMissing(let msg): return msg
        case .invalidItems(let msg): return msg
        }
    }
}

// MARK: - Protocol
public protocol TrackSSECBuildable {
    func build() throws -> TrackSSECData
}

// MARK: - Common base for all builders
/// Contains fields and setters common to all SSEC events.
/// Subclasses perform their own validations in `build()`.
public class _CommonSSECBuilder: TrackSSECBuildable {
    // product.*
    public var productId: String?
    public var productName: String?
    public var productPicture: [String]?
    public var productUrl: String?
    public var productAvailable: Int64?
    public var productCategoryPaths: [String]?
    public var productCategoryId: Int64?
    public var productCategory: String?
    public var productDescription: String?
    public var productVendor: String?
    public var productModel: String?
    public var productType: String?
    public var productPrice: Double?
    public var productOldPrice: Double?

    // other
    public var email: String?
    public var updatePerItem: Int64?
    public var update: Int64?

    // transaction.*
    public var transactionId: String?
    public var transactionDt: String?
    public var transactionSum: Double?
    public var transactionDiscount: Double?
    public var transactionStatus: Int64?

    // delivery / payment
    public var deliveryDt: String?
    public var deliveryPrice: Double?
    public var paymentDt: String?

    // items
    public var items: [OrderItem]?

    public init() {}

    // MARK: Chain setters

    @discardableResult
    public func setProduct(
        id: String? = nil,
        name: String? = nil,
        dateTime: String? = nil,
        picture: [String]? = nil,
        url: String? = nil,
        available: Int64? = nil,
        categoryPaths: [String]? = nil,
        categoryId: Int64? = nil,
        category: String? = nil,
        description: String? = nil,
        vendor: String? = nil,
        model: String? = nil,
        type: String? = nil,
        price: Double? = nil,
        oldPrice: Double? = nil
    ) -> Self {
        self.productId = id
        self.productName = name
        self.productPicture = picture
        self.productUrl = url
        self.productAvailable = available
        self.productCategoryPaths = categoryPaths
        self.productCategoryId = categoryId
        self.productCategory = category
        self.productDescription = description
        self.productVendor = vendor
        self.productModel = model
        self.productType = type
        self.productPrice = price
        self.productOldPrice = oldPrice
        return self
    }

    @discardableResult
    public func setTransaction(
        id: String? = nil,
        dt: String? = nil,
        sum: Double? = nil,
        discount: Double? = nil,
        status: Int64? = nil
    ) -> Self {
        self.transactionId = id
        self.transactionDt = dt
        self.transactionSum = sum
        self.transactionDiscount = discount
        self.transactionStatus = status
        return self
    }

    @discardableResult
    public func setDelivery(dt: String? = nil, deliveryPrice: Double? = nil) -> Self {
        self.deliveryDt = dt
        self.deliveryPrice = deliveryPrice
        return self
    }

    @discardableResult
    public func setPayment(dt: String? = nil) -> Self {
        self.paymentDt = dt
        return self
    }

    @discardableResult
    public func setEmail(_ email: String?) -> Self {
        self.email = email
        return self
    }

    /// `update` — флаг обновления целиком, `isUpdatePerItem` — построчно.
    @discardableResult
    public func setUpdate(isUpdate: Bool? = nil, isUpdatePerItem: Bool? = nil) -> Self {
        if let u = isUpdate { self.update = u ? 1 : 0 }
        if let upi = isUpdatePerItem { self.updatePerItem = upi ? 1 : 0 }
        return self
    }

    @discardableResult
    public func setItems(_ items: [OrderItem]) -> Self {
        self.items = items
        return self
    }

    /// Builds a `TrackSSECData` from the accumulated common fields only.
    /// Subclasses should call this and then apply their validations.
    public func buildCommon() -> TrackSSECData {
        return TrackSSECData(
            productId: productId,
            productName: productName,
            picture: productPicture,
            url: productUrl,
            available: productAvailable,
            categoryPaths: productCategoryPaths,
            categoryId: productCategoryId,
            category: productCategory,
            description: productDescription,
            vendor: productVendor,
            model: productModel,
            type: productType,
            price: productPrice,
            oldPrice: productOldPrice,
            email: email,
            updatePerItem: updatePerItem,
            update: update,
            transactionId: transactionId,
            transactionDt: transactionDt,
            transactionStatus: transactionStatus,
            transactionDiscount: transactionDiscount,
            transactionSum: transactionSum,
            deliveryDt: deliveryDt,
            deliveryPrice: deliveryPrice,
            paymentDt: paymentDt,
            items: items
        )
    }

    // default impl; subclasses override with validation
    public func build() throws -> TrackSSECData { buildCommon() }
}

// MARK: - View Product
public final class ViewProductBuilder: _CommonSSECBuilder {
    public override func build() throws -> TrackSSECData {
        guard productId != nil else {
            throw TrackBuildError.requiredFieldMissing("product.id is required for VIEW_PRODUCT")
        }
        return buildCommon()
    }
}

// MARK: - Order
public final class OrderBuilder: _CommonSSECBuilder {
    public override func build() throws -> TrackSSECData {
        guard transactionId != nil else { throw TrackBuildError.requiredFieldMissing("transaction.id is required for ORDER") }
        guard transactionDt != nil else { throw TrackBuildError.requiredFieldMissing("transaction.dt is required for ORDER") }
        guard transactionSum != nil else { throw TrackBuildError.requiredFieldMissing("transaction.sum is required for ORDER") }
        guard transactionStatus != nil else { throw TrackBuildError.requiredFieldMissing("transaction.status is required for ORDER") }
        // items для ORDER не обязательно, но если update == 1 — требуем
        if update == 1, (items?.isEmpty ?? true) {
            throw TrackBuildError.requiredFieldMissing("items must be provided for ORDER when 'update' == 1")
        }
        return buildCommon()
    }
}

// MARK: - Basket Add
public final class BasketAddBuilder: _CommonSSECBuilder {
    public override func build() throws -> TrackSSECData {
        guard transactionId != nil else { throw TrackBuildError.requiredFieldMissing("transaction.id is required for BASKET_ADD") }
        guard transactionDt != nil else { throw TrackBuildError.requiredFieldMissing("transaction.dt is required for BASKET_ADD") }
        guard let items, !items.isEmpty else {
            throw TrackBuildError.requiredFieldMissing("items must be provided for BASKET_ADD")
        }
        let hasBad = items.contains { $0.id.isEmpty || $0.price == nil || $0.qnt == nil }
        if hasBad { throw TrackBuildError.invalidItems("items must contain id, price & qnt for BASKET_ADD") }
        // по требованиям BASKET_ADD — update_per_item = 0
        self.updatePerItem = 0
        return buildCommon()
    }
}

// MARK: - Basket Clear
public final class BasketClearBuilder: _CommonSSECBuilder {
    public override func build() throws -> TrackSSECData {
        guard let items, !items.isEmpty else {
            throw TrackBuildError.requiredFieldMissing("items must be provided for BASKET_CLEAR")
        }
        let hasBad = items.contains { $0.id.isEmpty }
        if hasBad { throw TrackBuildError.invalidItems("items must contain id for BASKET_CLEAR") }
        return buildCommon()
    }
}

// MARK: - Factory
public enum TrackSSECDataBuilders {
    public static func viewProduct() -> ViewProductBuilder { .init() }
    public static func order() -> OrderBuilder { .init() }
    public static func basketAdd() -> BasketAddBuilder { .init() }
    public static func basketClear() -> BasketClearBuilder { .init() }
}
