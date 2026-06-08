import 'package:socket_io_client/socket_io_client.dart' as io;
import '../utils/debug_logger.dart';

class SocketService {
  static const _tag = 'SocketService';
  static const _baseUrl = 'https://wakeell.microdesk.tech';

  static final SocketService _instance = SocketService._();
  factory SocketService() => _instance;
  SocketService._();

  io.Socket? _socket;

  void connect(String token) {
    if (_socket != null && _socket!.connected) return;
    _socket = io.io(
      _baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
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
