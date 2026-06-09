class TopProductDTO {
  final String productName;
  final int quantitySold;

  TopProductDTO({required this.productName, required this.quantitySold});

  factory TopProductDTO.fromJson(Map<String, dynamic> json) {
    return TopProductDTO(
      productName: json['productName'] ?? '',
      quantitySold: (json['quantitySold'] ?? 0).toInt(),
    );
  }
}
