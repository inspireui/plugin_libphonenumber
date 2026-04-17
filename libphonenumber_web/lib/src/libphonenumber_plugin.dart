// Wasm-compat web implementation of libphonenumber.
//
// The upstream `libphonenumber_web` relies on the `libphonenumber.js`
// global loaded in index.html, talking to it via `package:js`'s
// `@JS()` annotations. That interop doesn't compile to WebAssembly
// (dart:_js_annotations + dart:js_util are JS-only), so this fork
// replaces the entire bridge with pure-Dart fallbacks.
//
// Runtime behaviour on web: phone formatting / validation are best-effort
// stubs — they return the input unchanged and treat any 7-15 digit number
// as valid. Mobile builds still use the native platform channel in
// libphonenumber_platform_interface for real parsing.
//
// Only users who specifically need live phone-number format validation on
// the web target are affected. This fork prioritises dart2wasm compile over
// that edge feature.

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:libphonenumber_platform_interface/libphonenumber_platform_interface.dart';

class LibPhoneNumberPlugin extends LibPhoneNumberPlatform {
  static void registerWith(Registrar registrar) {
    LibPhoneNumberPlatform.instance = LibPhoneNumberPlugin();
  }

  @override
  Future<bool?> isValidPhoneNumber(String phoneNumber, String isoCode) async {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15;
  }

  @override
  Future<String?> normalizePhoneNumber(String phoneNumber, String isoCode,
      [PhoneNumberFormat format = PhoneNumberFormat.E164]) async {
    final hasPlus = phoneNumber.trimLeft().startsWith('+');
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return hasPlus ? '+$digits' : digits;
  }

  @override
  Future<Map<String, dynamic>?> getRegionInfo(
      String phoneNumber, String isoCode) async {
    return RegionInfo(
      isoCode: isoCode.toUpperCase(),
      regionPrefix: '',
      formattedPhoneNumber: phoneNumber,
    ).toJson();
  }

  @override
  Future<int?> getNumberType(String phoneNumber, String isoCode) async {
    // 0 = FIXED_LINE / UNKNOWN — safest no-op default.
    return 0;
  }

  @override
  Future<String?> formatAsYouType(String phoneNumber, String isoCode) async {
    return phoneNumber;
  }

  @override
  Future<List<String>?> getAllCountries() async {
    return const <String>[];
  }

  @override
  Future<String?> getFormattedExampleNumber(
      String isoCode, PhoneNumberType type, PhoneNumberFormat format) async {
    return '';
  }
}
