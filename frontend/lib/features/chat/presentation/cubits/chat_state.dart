import 'package:equatable/equatable.dart';
import '../../data/models/chat_message_model.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessageModel> messages;
  const ChatLoaded(this.messages);

  ChatLoaded withMessage(ChatMessageModel msg) =>
      ChatLoaded([...messages, msg]);

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}
