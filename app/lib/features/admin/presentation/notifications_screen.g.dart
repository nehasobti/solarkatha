// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myNotifications)
final myNotificationsProvider = MyNotificationsProvider._();

final class MyNotificationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AppNotification>>,
          List<AppNotification>,
          Stream<List<AppNotification>>
        >
    with
        $FutureModifier<List<AppNotification>>,
        $StreamProvider<List<AppNotification>> {
  MyNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myNotificationsHash();

  @$internal
  @override
  $StreamProviderElement<List<AppNotification>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AppNotification>> create(Ref ref) {
    return myNotifications(ref);
  }
}

String _$myNotificationsHash() => r'2890ba17fa6583b274be70828c3f26e9339e86b6';
