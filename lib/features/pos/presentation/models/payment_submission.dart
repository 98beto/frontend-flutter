class PaymentSubmission {
  const PaymentSubmission({
    required this.method,
    this.receivedAmount,
    this.changeAmount,
  });

  final String method;
  final double? receivedAmount;
  final double? changeAmount;
}
