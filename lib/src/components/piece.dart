enum ChessPieceType { pawn, rook, knight, bishop, queen, king }

class ChessPiece {
  late final ChessPieceType type;
  late final bool isWhite;

  ChessPiece({required this.type, required this.isWhite});

  ChessPiece.fromJson(Map<String, dynamic> json) {
    type = ChessPieceType.values.firstWhere((value) => value.toString() == 'ChessPieceType.${json['type']}');
    isWhite = json['isWhite'];
  }

  Map<String, dynamic> toJson() => {
    'type': type.toString().split('.').last,
    'isWhite': isWhite,
  };
}
