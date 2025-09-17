//
//  TrackSSECDataBuilder.swift
//  SendsaySDK
//
//  Created by Stas ProSky on 05.09.2025.
//  Copyright © 2025 Sendsay. All rights reserved.
//

import Foundation

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

public final class TrackSSECDataBuilder {
    private let type: TrackingSSECType

    // product.*
    private var productId: String?
    private var productName: String?
    private var productDateTime: String?
    private var productPicture: [String]?
    private var productUrl: String?
    private var productAvailable: Int64?
    private var productCategoryPaths: [String]?
    private var productCategoryId: Int64?
    private var productCategory: String?
    private var productDescription: String?
    private var productVendor: String?
    private var productModel: String?
    private var productType: String?
    private var productPrice: Double?
    private var productOldPrice: Double?

    // other
    private var email: String?
    private var updatePerItem: Int64?
    private var update: Int64?

    // transaction.*
    private var transactionId: String?
    private var transactionDt: String?
    private var transactionSum: Double?
    private var transactionDiscount: Double?
    private var transactionStatus: Int64?

    // delivery / payment
    private var deliveryDt: String?
    private var deliveryPrice: Double?
    private var paymentDt: String?

    // items
    private var items: [OrderItem]?

    // cp
    private var cpMap: [String: AnyCodable]?

    public init(type: TrackingSSECType) {
        self.type = type
    }

    // MARK: - Setters (чейнинг)

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
        self.productDateTime = dateTime
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
    public func setDelivery(dt: String, deliveryPrice: Double? = nil) -> Self {
        self.deliveryDt = dt
        self.deliveryPrice = deliveryPrice
        return self
    }

    @discardableResult
    public func setPayment(dt: String) -> Self {
        self.paymentDt = dt
        return self
    }

    @discardableResult
    public func setEmail(_ email: String) -> Self {
        self.email = email
        return self
    }

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

    /// Удобный способ передать произвольную карту cp
    @discardableResult
    public func setCP(_ cp: [String: Any]) -> Self {
        self.cpMap = cp.mapValues { AnyCodable($0) }
        return self
    }

    // MARK: - Build

    public func build() throws -> TrackSSECData {
        // Валидации по типу события
        switch type {
        case .viewProduct:
            guard productId != nil else {
                throw TrackBuildError.requiredFieldMissing("product.id is required for VIEW_PRODUCT")
            }

        case .order:
            guard transactionId != nil else {
                throw TrackBuildError.requiredFieldMissing("transaction.id is required for type ORDER")
            }
            guard transactionDt != nil else {
                throw TrackBuildError.requiredFieldMissing("transaction.dt is required for type ORDER")
            }
            guard transactionSum != nil else {
                throw TrackBuildError.requiredFieldMissing("transaction.sum is required for type ORDER")
            }
            guard transactionStatus != nil else {
                throw TrackBuildError.requiredFieldMissing("transaction.status is required for type ORDER")
            }
            if update == 1, (items?.isEmpty ?? true) {
                throw TrackBuildError.requiredFieldMissing("items must be provided for type ORDER and 'update' == 1")
            }

        case .basketAdd:
            guard transactionId != nil else {
                throw TrackBuildError.requiredFieldMissing("transaction.id is required for type BASKET_ADD")
            }
            guard transactionDt != nil else {
                throw TrackBuildError.requiredFieldMissing("transaction.dt is required for type BASKET_ADD")
            }
            guard let items, !items.isEmpty else {
                throw TrackBuildError.requiredFieldMissing("items must be provided for type BASKET_ADD")
            }
            let bad = items.contains { $0.id.isEmpty || $0.price == nil || $0.qnt == nil }
            if bad {
                throw TrackBuildError.invalidItems("items must contain id, price & qnt for type BASKET_ADD")
            }
            self.updatePerItem = 0

        case .basketClear:
//            guard productDateTime != nil else {
//                throw TrackBuildError.requiredFieldMissing("dt is required for type BASKET_CLEAR")
//            }
            guard let items, !items.isEmpty else {
                throw TrackBuildError.requiredFieldMissing("items must be provided for type BASKET_CLEAR")
            }
            let bad = items.contains { $0.id.isEmpty }
            if bad {
                throw TrackBuildError.invalidItems("items must contain id for type BASKET_CLEAR")
            }

        default:
            // другие события
            break
        }

        let formattedProductDateTime = productDateTime
        let formattedTransactionDt   = transactionDt
        let formattedDeliveryDt      = deliveryDt
        let formattedPaymentDt       = paymentDt

        return TrackSSECData(
            productId: productId,
            productName: productName,
            dateTime: formattedProductDateTime,
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
            transactionDt: formattedTransactionDt,
            transactionStatus: transactionStatus,
            transactionDiscount: transactionDiscount,
            transactionSum: transactionSum,
            deliveryDt: formattedDeliveryDt,
            deliveryPrice: deliveryPrice,
            paymentDt: formattedPaymentDt,
            items: items,
            cp: cpMap
        )
    }
}
