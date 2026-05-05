class CashCloseResult {
  const CashCloseResult({
    required this.expectedBalance,
    required this.actualBalance,
    required this.difference,
  });

  final double expectedBalance;
  final double actualBalance;
  final double difference;
}
