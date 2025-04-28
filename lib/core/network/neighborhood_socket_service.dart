import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class NeighborhoodSocketService {
  StompClient? stompClient;

  void connect({required void Function(Map<String, dynamic> event) onEvent}) {
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: 'http://localhost:8080/ws', // Change to your backend host if needed
        onConnect: (StompFrame frame) {
          stompClient!.subscribe(
            destination: '/topic/neighborhood',
            callback: (frame) {
              if (frame.body != null) {
                onEvent(jsonDecode(frame.body!));
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => print(error.toString()),
      ),
    );
    stompClient!.activate();
  }

  void disconnect() {
    stompClient?.deactivate();
  }
}
