import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class CreateCommand extends Command<int> {
  CreateCommand({required Logger logger}) : _logger = logger {
    argParser.addOption('app-name', help: 'The name of the application.');
  }

  final Logger _logger;

  @override
  String get description => 'Creates a new Flutter application.';

  @override
  String get name => 'create';

  @override
  Future<int> run() async {
    final appName = argResults?.rest.isNotEmpty ?? false
        ? (argResults?.rest.first ?? 'example')
        : _logger.prompt('What is the application name?');

    // Step 1: Set the package name
    final packageName =
        _logger.prompt('Set the package name (e.g., com.eway.$appName):');

    // Step 2: Select backend (Firebase or REST API)
    final useFirebase = _logger.chooseOne(
      'Is this application gonna use Firebase core or REST API?',
      choices: ['🔥 Firebase Core', '🌐 REST API'],
      defaultValue: '🔥 Firebase Core',
    );

    // Step 3: Localization (l10n)
    final useL10n =
        _logger.confirm('Is it a multi-language application (l10n)?');

    // Step 4: Themes
    final themeChoice = _logger.chooseOne(
      'Are we going to use themes?',
      choices: ['🌑 Dark Theme', '🌕 Light Theme', '💡 Both'],
      defaultValue: '💡 Both',
    );

    // Step 5: Multiple Environments
    final useMultipleEnvironments =
        _logger.confirm('Do you want to use multiple environments?');

    // Step 6: Firebase Notifications
    final setFirebaseNotifications =
        _logger.confirm('Do you want to set up Firebase Notifications?');

    // Step 7: State Management
    final stateManagement = _logger.chooseOne(
      'Which state management are you going to use?',
      choices: ['🔄 Riverpod', '🧱 BLoC', '⚡ Get'],
      defaultValue: '🔄 Riverpod',
    );

    // Step 8: Router
    final routerChoice = _logger.chooseOne(
      'What is your router?',
      choices: ['📍 App Router', '📍 Go Router'],
      defaultValue: '📍 Go Router',
    );

    // Copy the template to the new project directory
    await _copyTemplate(appName, packageName);

    // Post-processing: Update package name and app name using
    //the respective packages
    await _updatePackageAndAppName(appName, packageName);

    // Show summary of selected options
    _logger
      ..info('Summary of your choices:')
      ..info('App Name: $appName')
      ..info('Package Name: $packageName')
      ..info('Backend: $useFirebase')
      ..info('Localization: ${useL10n ? "Yes" : "No"}')
      ..info('Theme: $themeChoice')
      ..info('Multiple Environments: ${useMultipleEnvironments ? "Yes" : "No"}')
      ..info(
        'Firebase Notifications: ${setFirebaseNotifications ? "Yes" : "No"}',
      )
      ..info('State Management: $stateManagement')
      ..info('Router: $routerChoice');

    return ExitCode.success.code;
  }

  Future<void> _copyTemplate(String appName, String packageName) async {
    final templateDir = Directory(
      '../templates/riverpod_firebase_single_env_go_router_dark_theme_no_localized',
    );
    final appDir = Directory('./$appName');

    if (!templateDir.existsSync()) {
      _logger.err('Template directory not found!');
      return;
    }

    // Create project directory
    await appDir.create(recursive: true);

    // Copy the template
    await for (final entity in templateDir.list(recursive: true)) {
      final relativePath = entity.path.replaceFirst(templateDir.path, '');
      final targetPath = appDir.path + relativePath;

      if (entity is File) {
        await File(entity.path).copy(targetPath);
      } else if (entity is Directory) {
        await Directory(targetPath).create(recursive: true);
      }
    }

    _logger.info('Project "$appName" created successfully from template.');

    // Update import statements in all Dart files
    await _updateImportStatements(appDir, appName);
  }

  Future<void> _updateImportStatements(Directory appDir, String appName) async {
    final dartFiles = appDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in dartFiles) {
      var content = await file.readAsString();
      content = content.replaceAll(
        'package:riverpod_firebase_single_env_go_router_dark_theme_no_localized',
        'package:${appName.toLowerCase().replaceAll(' ', '_')}',
      );
      await file.writeAsString(content);
    }

    _logger.info('Import statements updated in all Dart files.');
  }

  Future<void> _updatePackageAndAppName(
    String appName,
    String packageName,
  ) async {
    final appDir = Directory('./$appName');

    // Navigate to the project directory
    Directory.current = appDir.path;

    // Update pubspec.yaml
    _logger.info('Updating pubspec.yaml...');
    final pubspecFile = File('pubspec.yaml');
    if (await pubspecFile.exists()) {
      var content = await pubspecFile.readAsString();
      content = content.replaceFirst(
        RegExp(r'name: .*'),
        'name: ${appName.toLowerCase().replaceAll(' ', '_')}',
      );
      await pubspecFile.writeAsString(content);
      _logger.info('pubspec.yaml updated successfully.');
    } else {
      _logger.err('pubspec.yaml not found!');
    }

    // Run flutter pub get
    _logger.info('Running flutter pub get...');
    final pubGetResult = await Process.run('flutter', ['pub', 'get']);
    if (pubGetResult.exitCode != 0) {
      _logger.err('Failed to run flutter pub get: ${pubGetResult.stderr}');
      return;
    }
    _logger.info('Dependencies installed successfully.');

    // Update the package name using change_app_package_name
    _logger.info('Updating package name to "$packageName"...');
    final changePackageResult = await Process.run('dart', [
      'run',
      'change_app_package_name:main',
      packageName,
    ]);
    if (changePackageResult.exitCode != 0) {
      _logger
          .err('Failed to update package name: ${changePackageResult.stderr}');
      return;
    }
    _logger.info('Package name updated successfully.');

    // Update app name
    _logger.info('Updating app name to "$appName"...');
    final renameAppResult = await Process.run('dart', [
      'run',
      'rename_app:main',
      'all=$appName',
    ]);
    if (renameAppResult.exitCode != 0) {
      _logger.err('Failed to update app name: ${renameAppResult.stderr}');
      return;
    }
    _logger.info('App name updated successfully.');
  }
}
