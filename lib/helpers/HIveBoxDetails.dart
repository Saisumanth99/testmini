import 'package:hive/hive.dart';

class HiveBoxDetails {
  static String hiveboxName = 'coreDatabase';
  static String prefboxName = 'prefDatabase';

  static Box box = Hive.box(hiveboxName);
  static Box prefbox = Hive.box(prefboxName);
}
