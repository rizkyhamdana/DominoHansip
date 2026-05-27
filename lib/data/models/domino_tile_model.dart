import 'package:equatable/equatable.dart';

class DominoTileModel extends Equatable {
  final int sideA;
  final int sideB;
  final bool isFlipped;

  const DominoTileModel(this.sideA, this.sideB, {this.isFlipped = false});

  bool get isDouble => sideA == sideB;
  int get totalPips => sideA + sideB;

  DominoTileModel copyWith({bool? isFlipped}) {
    return DominoTileModel(
      sideA,
      sideB,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }

  Map<String, dynamic> toJson() => {
        'sideA': sideA,
        'sideB': sideB,
        'isFlipped': isFlipped,
      };

  factory DominoTileModel.fromJson(Map<String, dynamic> json) =>
      DominoTileModel(
        json['sideA'] as int,
        json['sideB'] as int,
        isFlipped: json['isFlipped'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [sideA, sideB, isFlipped];
}
