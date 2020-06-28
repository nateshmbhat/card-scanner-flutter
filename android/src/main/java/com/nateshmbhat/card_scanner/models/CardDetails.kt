package com.nateshmbhat.card_scanner.models

//@author nateshmbhat created on 27,June,2020

data class CardDetails(
        private var cardNumber: String,
        private var cardIssuer: String = "",
        private var cardHolderName: String = "",
        private var validFromDate: String = "",
        private var expiryDate: String = "") {
}