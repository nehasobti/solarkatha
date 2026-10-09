// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(projectsRepository)
final projectsRepositoryProvider = ProjectsRepositoryProvider._();

final class ProjectsRepositoryProvider
    extends
        $FunctionalProvider<
          ProjectsRepository,
          ProjectsRepository,
          ProjectsRepository
        >
    with $Provider<ProjectsRepository> {
  ProjectsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProjectsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProjectsRepository create(Ref ref) {
    return projectsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectsRepository>(value),
    );
  }
}

String _$projectsRepositoryHash() =>
    r'89e221dc00ec78dc0816def0fc136b727b43a9e3';

@ProviderFor(projectList)
final projectListProvider = ProjectListProvider._();

final class ProjectListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProjectSummary>>,
          List<ProjectSummary>,
          Stream<List<ProjectSummary>>
        >
    with
        $FutureModifier<List<ProjectSummary>>,
        $StreamProvider<List<ProjectSummary>> {
  ProjectListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectListHash();

  @$internal
  @override
  $StreamProviderElement<List<ProjectSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ProjectSummary>> create(Ref ref) {
    return projectList(ref);
  }
}

String _$projectListHash() => r'913bd8890267ad1a71c915c002e1acacdf7a7726';

@ProviderFor(projectSummary)
final projectSummaryProvider = ProjectSummaryFamily._();

final class ProjectSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProjectSummary?>,
          ProjectSummary?,
          Stream<ProjectSummary?>
        >
    with $FutureModifier<ProjectSummary?>, $StreamProvider<ProjectSummary?> {
  ProjectSummaryProvider._({
    required ProjectSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectSummaryHash();

  @override
  String toString() {
    return r'projectSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ProjectSummary?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ProjectSummary?> create(Ref ref) {
    final argument = this.argument as String;
    return projectSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectSummaryHash() => r'f7ceef7c9f77602ad757fc78a50109d34cbe27df';

final class ProjectSummaryFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ProjectSummary?>, String> {
  ProjectSummaryFamily._()
    : super(
        retry: null,
        name: r'projectSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectSummaryProvider call(String id) =>
      ProjectSummaryProvider._(argument: id, from: this);

  @override
  String toString() => r'projectSummaryProvider';
}

@ProviderFor(projectStages)
final projectStagesProvider = ProjectStagesFamily._();

final class ProjectStagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StageRow>>,
          List<StageRow>,
          Stream<List<StageRow>>
        >
    with $FutureModifier<List<StageRow>>, $StreamProvider<List<StageRow>> {
  ProjectStagesProvider._({
    required ProjectStagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectStagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectStagesHash();

  @override
  String toString() {
    return r'projectStagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<StageRow>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<StageRow>> create(Ref ref) {
    final argument = this.argument as String;
    return projectStages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectStagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectStagesHash() => r'3c94ceac753429f7f92df41a1114165050a1acc8';

final class ProjectStagesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<StageRow>>, String> {
  ProjectStagesFamily._()
    : super(
        retry: null,
        name: r'projectStagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectStagesProvider call(String projectId) =>
      ProjectStagesProvider._(argument: projectId, from: this);

  @override
  String toString() => r'projectStagesProvider';
}

@ProviderFor(leadProject)
final leadProjectProvider = LeadProjectFamily._();

final class LeadProjectProvider
    extends
        $FunctionalProvider<AsyncValue<Project?>, Project?, Stream<Project?>>
    with $FutureModifier<Project?>, $StreamProvider<Project?> {
  LeadProjectProvider._({
    required LeadProjectFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'leadProjectProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$leadProjectHash();

  @override
  String toString() {
    return r'leadProjectProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Project?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Project?> create(Ref ref) {
    final argument = this.argument as String;
    return leadProject(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LeadProjectProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$leadProjectHash() => r'78f3e00d57c0bf22d5ef4f453790a341bbeffb06';

final class LeadProjectFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Project?>, String> {
  LeadProjectFamily._()
    : super(
        retry: null,
        name: r'leadProjectProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LeadProjectProvider call(String leadId) =>
      LeadProjectProvider._(argument: leadId, from: this);

  @override
  String toString() => r'leadProjectProvider';
}

@ProviderFor(projectAssignees)
final projectAssigneesProvider = ProjectAssigneesFamily._();

final class ProjectAssigneesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  ProjectAssigneesProvider._({
    required ProjectAssigneesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectAssigneesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectAssigneesHash();

  @override
  String toString() {
    return r'projectAssigneesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return projectAssignees(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectAssigneesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectAssigneesHash() => r'd806189ab4b09585f27ca8f3338f92666641f61a';

final class ProjectAssigneesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<String>>, String> {
  ProjectAssigneesFamily._()
    : super(
        retry: null,
        name: r'projectAssigneesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectAssigneesProvider call(String projectId) =>
      ProjectAssigneesProvider._(argument: projectId, from: this);

  @override
  String toString() => r'projectAssigneesProvider';
}
