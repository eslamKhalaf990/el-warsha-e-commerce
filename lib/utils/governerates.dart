class Governorates {
  /*
  *     static {
        // --- Zone 1: Metro & Delta (Lower Cost - 55 EGP) ---
        SHIPPING_RATES.put("القاهرة", 65.0);
        SHIPPING_RATES.put("الجيزة", 65.0);
        SHIPPING_RATES.put("القليوبية", 65.0);
        SHIPPING_RATES.put("المنوفية", 70.0);
        SHIPPING_RATES.put("الشرقية", 70.0);
        SHIPPING_RATES.put("الغربية", 70.0);

        // --- Zone 2: Coastal, Canal & North Upper Egypt (65 EGP) ---
        SHIPPING_RATES.put("الإسكندرية", 70.0);
        SHIPPING_RATES.put("البحيرة", 70.0);
        SHIPPING_RATES.put("الدقهلية", 70.0);
        SHIPPING_RATES.put("كفر الشيخ", 70.0);
        SHIPPING_RATES.put("الإسماعيلية", 75.0);
        SHIPPING_RATES.put("السويس", 75.0);
        SHIPPING_RATES.put("بورسعيد", 75.0);
        SHIPPING_RATES.put("الفيوم", 80.0);
        SHIPPING_RATES.put("بني سويف", 80.0);
        SHIPPING_RATES.put("المنيا", 80.0);
        SHIPPING_RATES.put("دمياط", 80.0);
        SHIPPING_RATES.put("دمياط الجديدة", 80.0);

        // --- Zone 3: Middle Upper Egypt & Sinai (80 EGP) ---
        SHIPPING_RATES.put("أسيوط", 80.0);
        SHIPPING_RATES.put("شمال سيناء", 80.0);
        SHIPPING_RATES.put("جنوب سيناء", 80.0);

        // --- Zone 4: Remote & Deep South (90 EGP) ---
        SHIPPING_RATES.put("سوهاج", 110.0);
        SHIPPING_RATES.put("البحر الأحمر", 110.0);
        SHIPPING_RATES.put("مطروح", 110.0);

        // --- Zone 5: Furthest South (100 EGP) ---
        SHIPPING_RATES.put("قنا", 110.0);
        SHIPPING_RATES.put("الأقصر", 110.0);
        SHIPPING_RATES.put("أسوان", 110.0);

        // --- Zone 6: Special (105 EGP) ---
        SHIPPING_RATES.put("الوادي الجديد", 120.0);
    }

  * */

  static const Map<String, double> shippingRates = {
    // --- Zone 1: Metro & Delta ---
    'القاهرة': 80.0,
    'الجيزة': 80.0,
    'القليوبية': 100.0,
    'المنوفية': 100.0,
    'الشرقية': 100.0,
    'الغربية': 100.0,

    // --- Zone 2: Coastal, Canal & North Upper Egypt ---
    'الإسكندرية': 90.0,
    'البحيرة': 100.0,
    'الدقهلية': 100.0,
    'كفر الشيخ': 100.0,
    'الإسماعيلية': 100.0,
    'السويس': 100.0,
    'بورسعيد': 100.0,
    'الفيوم': 110.0,
    'بني سويف': 110.0,
    'المنيا': 110.0,
    'دمياط': 100.0,
    'دمياط الجديدة': 100.0,

    // --- Zone 3: Middle Upper Egypt & Sinai ---
    'أسيوط': 120.0,
    'شمال سيناء': 130.0,
    'جنوب سيناء': 130.0,

    // --- Zone 4: Remote & Deep South ---
    'سوهاج': 120.0,
    'البحر الأحمر': 120.0,
    'مطروح': 130.0,

    // --- Zone 5: Furthest South ---
    'قنا': 120.0,
    'الأقصر': 120.0,
    'أسوان': 120.0,

    // --- Zone 6: Special ---
    'الوادي الجديد': 130.0,
  };

  static List<String> get list => shippingRates.keys.toList();

  static bool isValid(String? input) {
    if (input == null || input.isEmpty) return false;
    return shippingRates.containsKey(_normalize(input));
  }

  static double getDeliveryPrice(String city) {
    String normalizedCity = _normalize(city);
    if (!shippingRates.containsKey(normalizedCity)) {
      return 65;
    }
    return shippingRates[normalizedCity]!;
  }

  static String _normalize(String input) {
    String text = input.trim();

    if (text.endsWith('ه') && text != 'الله') {
      text = '${text.substring(0, text.length - 1)}ة';
    }

    if (text == 'الاقصر') return 'الأقصر';
    if (text == 'اسوان') return 'أسوان';
    if (text == 'اسيوط') return 'أسيوط';
    if (text == 'الاسكندرية' || text == 'الاسكندريه') return 'الإسكندرية';
    if (text == 'الاسماعيلية' || text == 'الاسماعيليه') return 'الإسماعيلية';
    if (text == 'جيزة') return 'الجيزة';
    if (text == 'الجيزه') return 'الجيزة';
    if (text == 'القاهره') return 'القاهرة';

    return text;
  }
}