import 'package:pro.stations.wetaxi.ma/core/storage/local_storage.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/domain/entities/driver_entity.dart';
import 'package:pro.stations.wetaxi.ma/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final LocalStorage _storage;

  AuthRepositoryImpl(this._dataSource, this._storage);

  @override
  Future<DriverEntity> login(String phone, String password) async {
    final data = await _dataSource.login(phone, password);
    final token = data['token'] as String;
    await _storage.saveToken(token);
    final driver = _mapDriver(data['driver'] as Map<String, dynamic>);
    if (driver.station != null) {
      await _storage.saveStationId(driver.station!.id);
    }
    return driver;
  }

  @override
  Future<DriverEntity> getProfile() async {
    final data = await _dataSource.getProfile();
    return _mapDriver(data['driver'] as Map<String, dynamic>);
  }

  @override
  Future<bool> isAuthenticated() => _storage.hasToken();

  @override
  Future<void> logout() => _storage.clear();

  @override
  Future<String?> getToken() => _storage.getToken();

  DriverEntity _mapDriver(Map<String, dynamic> d) {
    StationEntity? station;
    if (d['station'] is Map<String, dynamic>) {
      final s = d['station'] as Map<String, dynamic>;
      station = StationEntity(
        id: (s['_id'] ?? s['id'] ?? '') as String,
        name: (s['name'] ?? '') as String,
        code: s['code'] as String?,
        city: s['city'] as String?,
      );
    }

    final lines = <LineEntity>[];
    if (d['selectedLines'] is List) {
      for (final l in d['selectedLines'] as List) {
        if (l is Map<String, dynamic>) {
          lines.add(LineEntity(
            id: (l['_id'] ?? l['id'] ?? '') as String,
            origin: (l['origin'] ?? '') as String,
            destination: (l['destination'] ?? '') as String,
            price: (l['price'] as num?)?.toDouble() ?? 0,
          ));
        }
      }
    }

    return DriverEntity(
      id: (d['id'] ?? d['_id'] ?? '') as String,
      name: (d['name'] ?? '') as String,
      phone: (d['phone'] ?? '') as String,
      taxiNumber: (d['taxiNumber'] ?? '') as String,
      plateNumber: (d['plateNumber'] ?? '') as String,
      permitNumber: d['permitNumber'] as String?,
      balance: (d['balance'] as num?)?.toDouble() ?? 0,
      nfcTagId: d['nfcTagId'] as String?,
      station: station,
      selectedLines: lines,
    );
  }
}
