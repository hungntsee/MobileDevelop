class Student {
  static const tblStudent = 'students';
  static const colId = 'id';
  static const colName = 'name';
  static const colMobile = 'mobile';

  int? id;
  String? name;
  String? mobile;

  Student({this.id, this.name, this.mobile});

  Student.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    name = map[colName];
    mobile = map[colMobile];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'name': name, 'mobile': mobile};
    if (id != null) map[colId] = id;
    return map;
  }
}
