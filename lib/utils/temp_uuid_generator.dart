import 'package:uuid/uuid.dart';

final _uuid = Uuid();

String generateTempUuid() {
  return 'tmp-${_uuid.v4()}';
}
