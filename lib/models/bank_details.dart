// lib/models/bank_details.dart

/// Stores the company's banking/payment information managed by admin.
class BankDetails {
  String bankName;
  String accountNumber;
  String accountName;
  String promptPayId; // e.g. phone number or tax ID for PromptPay
  String? qrCodeUrl; // URL or asset path of the QR code image

  BankDetails({
    this.bankName = 'Kasikorn Bank (KBank)',
    this.accountNumber = '1234567890',
    this.accountName = 'ShopEase Co., Ltd.',
    this.promptPayId = '0812345678',
    this.qrCodeUrl,
  });

  BankDetails copyWith({
    String? bankName,
    String? accountNumber,
    String? accountName,
    String? promptPayId,
    String? qrCodeUrl,
  }) {
    return BankDetails(
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      promptPayId: promptPayId ?? this.promptPayId,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
    );
  }
}
