import 'package:flutter/material.dart';

abstract class AppColors {
  static const defaultIconColor = 0xFF00B3FF;
}

abstract class BorderRadii {
  static BorderRadius gentlyRounded = BorderRadius.circular(10);
}

/// It is required to use the emoji font, otherwise emojis
/// all appear as simple black and white glyphs.
const emojiFont = 'Noto Color Emoji';

abstract class Spacers {
  static const horizontalSmall = SizedBox(width: 20);

  static const verticalXtraSmall = SizedBox(height: 10);
  static const verticalSmall = SizedBox(height: 20);
  static const verticalMedium = SizedBox(height: 30);
  static const verticalLarge = SizedBox(height: 40);
}

class TextStyles {
  static const TextStyle base = TextStyle();

  static TextStyle body1 = base.copyWith(fontSize: 15);

  static TextStyle link1 = body1.copyWith(color: Colors.lightBlueAccent);

  static TextStyle headline1 = base.copyWith(fontSize: 20);
}
