import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase/supabase_providers.dart';

part 'assistant_api.g.dart';

class ChatTurn {
  const ChatTurn({required this.fromUser, required this.text});

  final bool fromUser;
  final String text;

  Map<String, String> toJson() => {
    'role': fromUser ? 'user' : 'model',
    'text': text,
  };
}

/// Too many questions from this network (or today overall).
class AssistantRateLimited implements Exception {
  const AssistantRateLimited();
}

/// Public product Q&A (the `assistant` Edge Function, no login needed).
class AssistantApi {
  AssistantApi(this._client);

  final SupabaseClient _client;

  Future<String> ask(List<ChatTurn> turns, String lang) async {
    try {
      final res = await _client.functions.invoke(
        'assistant',
        body: {
          'messages': [for (final t in turns) t.toJson()],
          'lang': lang,
        },
      );
      final reply = (res.data as Map?)?['reply'];
      if (reply is String && reply.isNotEmpty) return reply;
      throw StateError('empty reply');
    } on FunctionException catch (e) {
      if (e.status == 429) throw const AssistantRateLimited();
      rethrow;
    }
  }
}

@Riverpod(keepAlive: true)
AssistantApi assistantApi(Ref ref) =>
    AssistantApi(ref.watch(supabaseClientProvider));
