import 'package:inner_child_app/core/constants/app_constants.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;

  late HubConnection _connection;

  SignalRService._internal();

  Future<void> initConnection() async {
    _connection = HubConnectionBuilder()
        .withUrl('${AppConstants.baseURL}hub/session')
        .build();

    // Set up default message handler
    _connection.on('ReceiveMessage', (args) {
      print("🎯 SignalR ReceiveMessage: $args");
    });

    await _connection.start();
    print("✅ SignalR connected");

    await _connection.invoke("RegisterConnection");
    print("📌 Registered connection on server");
  }

  Future<void> initConnectionAuthorize(String token) async {
    _connection = HubConnectionBuilder()
        .withUrl('${AppConstants.baseURL}hub/session?token=$token')
        .build();

    // Set up default message handler
    _connection.on('ReceiveMessage', (args) {
      print("🎯 SignalR ReceiveMessage: $args");
    });

    await _connection.start();
    print("✅ SignalR connected ${_connection.connectionId}");

    await _connection.invoke("RegisterConnection");
    print("📌 Registered connection on server");
  }

  // Generic message handler
  void onMessage(Function(List<Object?>?) handler) {
    _connection.on('ReceiveMessage', handler);
  }

  // Specific event handlers
  void onUserOnline(Function(List<Object?>?) handler) {
    _connection.on('UserOnline', handler);
  }

  void onUserOffline(Function(List<Object?>?) handler) {
    _connection.on('UserOffline', handler);
  }

  void onNotification(Function(List<Object?>?) handler) {
    _connection.on('NewNotification', handler);
  }

  void onSystemMaintenance(Function(List<Object?>?) handler) {
    _connection.on('SystemMaintenance', handler);
  }

  void onForceLogout(Function(List<Object?>?) handler) {
    _connection.on('force_logout', handler);
  }

  // Methods to send messages
  Future<void> sendMessage(String user, String message) async {
    await _connection.invoke('SendMessage', args: [user, message]);
  }

  Future<void> joinGroup(String groupName) async {
    await _connection.invoke('JoinGroup', args: [groupName]);
  }

  Future<void> leaveGroup(String groupName) async {
    await _connection.invoke('LeaveGroup', args: [groupName]);
  }

  Future<void> stopConnection() async {
    await _connection.stop();
    print("🛑 SignalR stopped");
  }
}

// import 'package:inner_child_app/core/constants/app_constants.dart';
// import 'package:signalr_netcore/hub_connection.dart';
// import 'package:signalr_netcore/hub_connection_builder.dart';
//
// class SignalRService {
//   static final SignalRService _instance = SignalRService._internal();
//   factory SignalRService() => _instance;
//
//   late HubConnection _connection;
//
//   SignalRService._internal();
//
//   Future<void> initConnection() async {
//     _connection = HubConnectionBuilder()
//         .withUrl('${AppConstants.baseURL}hub/sessions')
//         .build();
//
//     _connection.on('ReceiveMessage', (args) {
//       print("🎯 SignalR message received: $args");
//     });
//
//     await _connection.start();
//     print("✅ SignalR connected");
//   }
//
//   void onMessage(Function(List<Object?>?) handler) {
//     _connection.on('ReceiveMessage', handler);
//   }
//
//   Future<void> stopConnection() async {
//     await _connection.stop();
//     print("🛑 SignalR stopped");
//   }
// }
