//
//  Site.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 11/7/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import Foundation
class Site {
    public final let APP_NAME: String = "Phuck Brand"
    public final let PRIMARY_COLOR: Int = 0x000000
    public final let PROTOCOL: String = "https";
    public final let DOMAIN: String =  "whatsdown.in"; //"192.168.43.11"; // "192.168.43.223"; //"10.0.2.2"; //
    public final let ADDRESS: String
    public final let CART: String
    public final let ADD_TO_CART: String
    public final let PRODUCTS: String
    public final let SIMPLE_PRODUCTS: String
    public final let PRODUCT: String
    public final let PRODUCT_VARIATION: String
    public final let LOGIN: String
    public final let REGISTER: String
    public final let USER: String
    public final let UPDATE_SHIPPING: String
    public final let CREATE_ORDER: String
    public final let UPDATE_COUPON: String
    public final let CHANGE_CART_SHIPPING: String
    public final let ORDERS: String
    public final let ORDER: String
    public final let CATEGORIES: String
    public final let UPDATE_WALLET_ADDRESS: String
    public final let WALLET_ADDRESS: String
    public final let PHUCK_GAMERS: String
    public final let ADD_TO_WISH_LIST: String
    public final let REMOVE_FROM_WISH_LIST: String
    public final let WISH_LIST: String
    public final let BANNERS: String
    public final let COMPLETE_ORDER_PAGE: String
    public final let APPLY_REWARD: String
    
    init() {
        ADDRESS = PROTOCOL + "://" + DOMAIN + "/";
        CART = ADDRESS + "wp-json/skye-api/v1/cart/";
        ADD_TO_CART = ADDRESS + "wp-json/skye-api/v1/add-to-cart/";
        PRODUCTS = ADDRESS + "wp-json/skye-api/v1/products/";
        SIMPLE_PRODUCTS = ADDRESS + "wp-json/skye-api/v1/simple-products/";
        PRODUCT = ADDRESS + "wp-json/skye-api/v1/product/";
        PRODUCT_VARIATION = ADDRESS + "wp-json/skye-api/v1/product-variation/";
        LOGIN = ADDRESS + "wp-json/skye-api/v1/authenticate";
        REGISTER = ADDRESS + "wp-json/skye-api/v1/register/";
        USER = ADDRESS + "wp-json/skye-api/v1/user-info/";
        UPDATE_SHIPPING = ADDRESS + "wp-json/skye-api/v1/update-user-shipping-address/";
        CREATE_ORDER = ADDRESS + "wp-json/skye-api/v1/create-order/";
        UPDATE_COUPON = ADDRESS + "wp-json/skye-api/v1/update-cart-coupon/";
        CHANGE_CART_SHIPPING = ADDRESS + "wp-json/skye-api/v1/change-cart-shipping-method/";
        ORDERS = ADDRESS + "wp-json/skye-api/v1/orders/";
        ORDER = ADDRESS + "wp-json/skye-api/v1/order/";
        CATEGORIES = ADDRESS + "wp-json/skye-api/v1/categories/";
        UPDATE_WALLET_ADDRESS = ADDRESS + "wp-json/skye-api/v1/update-wallet-address/";
        WALLET_ADDRESS = ADDRESS + "wp-json/skye-api/v1/wallet-address/";
        PHUCK_GAMERS = ADDRESS + "wp-json/phuck-gamers/";
        ADD_TO_WISH_LIST = ADDRESS + "wp-json/skye-api/v1/add-to-wishlist/";
        REMOVE_FROM_WISH_LIST = ADDRESS + "wp-json/skye-api/v1/remove-from-wishlist/";
        WISH_LIST = ADDRESS + "wp-json/skye-api/v1/wishlists/";
        BANNERS = ADDRESS + "wp-json/skye-api/v1/banners/";
        COMPLETE_ORDER_PAGE = ADDRESS + "app-complete-order/";
        APPLY_REWARD = ADDRESS + "wp-json/skye-api/v1/apply-cart-reward/";
    }
    


    public final let CURRENCY: String = "$";
    public func payment_method_title(slug: String) -> String {
    var title: String = "";
    switch (slug) {
    case "cod":
    title = "Cash On Delivery";
    break;
    case "bacs":
    title = "Direct Bank Transfer";
    break;
    case "cheque":
    title = "Check Payments";
    break;
    case "paypal":
    title = "Paypal";
    break;
    case "stripe":
    title = "Stripe";
    break;
    case "stripe_cc":
    title = "Credit Cards";
    break;
    default:
    title = "No Payment method";
    break;

    }
    return title;
    }
    
    
    
}
