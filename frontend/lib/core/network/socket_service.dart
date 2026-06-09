import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../utils/debug_logger.dart';

/// dart:io returns port=0 for wss:// URIs because it only knows default ports
/// for http/https, not ws/wss. This adapter forces an explicit :443 so that
/// WebSocket.connect() never connects to port 0.
class _WssPortFixAdapter implements io.HttpClientAdapter {
  final _client = HttpClient();

  @override
  Future<WebSocket> connect(String uri,
      {Map<String, dynamic>? headers}) async {
    String fixed = uri;
    if (uri.startsWith('wss://')) {
      final parsed = Uri.parse(uri);
      if (parsed.port == 0) {
        fixed = uri.replaceFirst(
          'wss://${parsed.host}/',
          'wss://${parsed.host}:443/',
        );
      }
    }
    return WebSocket.connect(fixed, headers: headers, customClient: _client);
  }
}

class SocketService {
  static const _tag = 'SocketService';
  static const _host = 'wakeell.microdesk.tech';

  static final SocketService _instance = SocketService._();
  factory SocketService() => _instance;
  SocketService._();

  io.Socket? _socket;

  void connect(String token) {
    if (_socket != null && _socket!.connected) return;
    _socket?.disconnect();
    _socket = null;

    _socket = io.io(
      'https://$_host',
      <String, dynamic>{
        'transports': ['websocket'],
        'auth': {'token': token},
        'autoConnect': false,
        'forceNew': true,
        'hostname': _host,
        'port': 443,
        'secure': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 2000,
        'path': '/socket.io/',
        'httpClientAdapter': _WssPortFixAdapter(),
      },
    );
    _socket!.connect();
    _socket!.onConnect((_) => DebugLogger.log(_tag, 'connected'));
    _socket!.onDisconnect((_) => DebugLogger.log(_tag, 'disconnected'));
    _socket!.onConnectError((e) => DebugLogger.error(_tag, 'connect error: $e'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void emit(String event, dynamic data) => _socket?.emit(event, data);

  void on(String event, Function(dynamic) handler) => _socket?.on(event, handler);

  void off(String event) => _socket?.off(event);

  bool get isConnected => _socket?.connected ?? false;
}
