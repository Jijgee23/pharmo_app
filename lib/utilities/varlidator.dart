String? validateEmail(String? value) {
  const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
  final regex = RegExp(pattern);

  return value!.isNotEmpty && !regex.hasMatch(value)
      ? 'Имэйл хаяг буруу байна!'
      : null;
}
String? validatePassword(String? value) {
  final passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
  if (value == null || value.isEmpty) {
    return 'Нууц үгээ оруулна уу';
  }
  if (!passwordRegex.hasMatch(value)) {
    return 'Том, жижиг үсэг тоо заавал агуулна!';
  }
  return null;
}

String? validateOtp(String? value) {
  final otpRegex = RegExp(r'^\d{6}$');
  if (value == null || value.isEmpty) {
    return 'Нууц үгээ оруулна уу';
  }
  if (!otpRegex.hasMatch(value)) {
    return 'Нууц үг буруу байна!';
  }
  return null;
}

String? validatePhone(String? value) {
  final otpRegex = RegExp(r'^\d{8}$');
  if (value == null || value.isEmpty) {
    return 'Утасны дугаараа оруулна уу';
  }
  if (!otpRegex.hasMatch(value)) {
    return 'Утасны дугаар 8 оронтой байх ёстой!!';
  }
  return null;
}

String? validateCRD(String? value) {
  final otpRegex = RegExp(r'^\d{7}$');
  if (value == null || value.isEmpty) {
    return 'Регистрийн дугаар оруулна уу';
  }
  if (!otpRegex.hasMatch(value)) {
    return 'Регистрийн дугаар 7 оронтой байх ёстой!';
  }
  return null;
}
