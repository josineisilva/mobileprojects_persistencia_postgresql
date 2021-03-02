import 'package:postgresql2/postgresql.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper.internal();

  static var uri = 'postgres://mobile:mobile@10.0.2.2:5432/mobile';

  static Connection _conn;

  static Future<bool> initDb() async {
    if ( _conn == null ) {
      String _errorMsg;
      print("Conectando");
      _conn = await connect(uri).catchError((_error) {
        _errorMsg = _error.message;
      });
      if ( _conn == null )
        return Future<bool>.error(_errorMsg);
      else
        print("Conectado");
    }
    return true;
  }

  static Future<List<Map>> getAll(String _table) async {
    print("Database getAll");
    List<Map> ret = List<Map>();
    String _errorMsg = "";
    String _sql = "SELECT * FROM ${_table}";
    var _rows = await _conn.query(_sql)
      .toList().catchError((_error) {
        _errorMsg = _error.message+" on query "+_sql;
      });
    if (_errorMsg == "") {
      for (Row _row in _rows) {
        ret.add(_row.toMap());
      }
      return ret;
    } else
      return Future<List<Map>>.error(_errorMsg);
  }

  static Future<Map> getByID(String _table, int _id) async {
    print("Database getByID");
    Map ret;
    String _errorMsg = "";
    String _sql = "SELECT * FROM ${_table} WHERE id='${_id}'";
    var _rows = await _conn.query(_sql)
      .toList().catchError((_error) {
        _errorMsg = _error.message+" on query "+_sql;
      });
    if ( _rows != null ) {
      if (_rows.isNotEmpty)
        ret = _rows.first.toMap();
      else
        ret = Map();
      return ret;
    } else
      return Future<Map>.error(_errorMsg);
  }

  static Future<int> insert(String _table, Map _map) async {
    print("Database insert");
    int ret;
    String _errorMsg = "";
    String _sql = "SELECT COALESCE(MAX(id),0)+1 as id FROM ${_table}";
    var _rows = await _conn.query(
      _sql
    ).toList().catchError((_error) {
      _errorMsg = _error.message+" on query "+_sql;
    });
    if ( _rows != null ) {
      _map['id'] = _rows.first[0];
      String _fields = "";
      String _values = "";
      _map.forEach((_key, _value) {
        if (_fields != "")
          _fields += ",";
        _fields += _key;
        if (_values != "")
          _values += ",";
        _values += "'${_value}'";
      });
      String _sql = "INSERT INTO ${_table} (${_fields}) VALUES (${_values})";
      ret = await _conn.execute(_sql).catchError((_error) {
        _errorMsg = _error.message+" on query "+_sql;
      });
    }
    if (ret != null)
      return ret;
    else
      return Future<int>.error(_errorMsg);
  }

  static Future<int> update(String _table, Map _map) async {
    print("Database update");
    int ret;
    String _errorMsg = "";
    String _fields = "";
    _map.forEach((_key, _value) {
      if (_key != "id") {
        if (_fields != "")
          _fields += ",";
        _fields += "${_key}='${_value}'";
      }
    });
    String _sql = "UPDATE ${_table} SET ${_fields} WHERE id='${_map['id']}'";
    ret = await _conn.execute(_sql).catchError((_error) {
      _errorMsg = _error.message+" on query "+_sql;
    });
    if (ret != null)
      return ret;
    else
      return Future<int>.error(_errorMsg);
  }

  static Future<int> delete(String _table, int _id) async {
    print("Database delete");
    int ret;
    String _errorMsg = "";
    String _sql = "DELETE FROM "+_table+" WHERE id='${_id}'";
    ret = await _conn.execute(_sql).catchError((_error) {
      _errorMsg = _error.message+" on query "+_sql;
    });
    if (ret != null)
      return ret;
    else
      return Future<int>.error(_errorMsg);
  }

  void close() {
    print("CloseDB");
    _conn.close();
  }
}