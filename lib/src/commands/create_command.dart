import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

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

    // Step 7: State Management (only Riverpod is supported for now)
    final stateManagement = _logger.chooseOne(
      'Which state management are you going to use?',
      choices: ['🔄 Riverpod', '🧱 BLoC', '⚡ Get'],
      defaultValue: '🔄 Riverpod',
    );

    if (stateManagement != '🔄 Riverpod') {
      _logger.err('Currently, only Riverpod is supported.');
      _logger.info(
        'If you want to contribute to adding other state management systems, check out:',
      );
      _logger.info('https://github.com/hberkayozdemir/eway');
      return ExitCode.usage.code;
    }

    // Step 8: Router (this is valid for Riverpod)
    final routerChoice = _logger.chooseOne(
      'What is your router?',
      choices: ['📍 App Router', '📍 Go Router'],
      defaultValue: '📍 Go Router',
    );

    // Copy the appropriate Riverpod template based on environment choice
    final templateFolder = useMultipleEnvironments
        ? '../templates/riverpod/eway_riverpod_multi_base'
        : '../templates/riverpod/eway_riverpod_base';

    final templatePackageName =
        templateFolder.replaceAll('../templates/riverpod/', '');
    await _copyTemplate(
      appName,
      packageName,
      templateFolder,
      templatePackageName,
    );

    // Post-processing: Update package name and app name using the respective
    // packages
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

  Future<void> _updatePackageAndAppName(
    String appName,
    String packageName,
  ) async {
    final appDir = Directory('./$appName');

    // Check if the directory exists
    if (!await appDir.exists()) {
      _logger.err('Project directory does not exist: $appDir');
      return;
    }

    // Navigate to the project directory
    Directory.current = appDir.path;

    // Update pubspec.yaml
    _logger.info('Updating pubspec.yaml...');
    final pubspecFile = File('pubspec.yaml');
    if (await pubspecFile.exists()) {
      var content = await pubspecFile.readAsString();
      content = content.replaceFirst(
        RegExp('name: .*'),
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

  Future<void> _copyTemplate(
    String appName,
    String packageName,
    String templateFolder,
    String templatePackageName,
  ) async {
    final templateDir = Directory(templateFolder);
    // Create the app directory in the current working directory
    final appDir = Directory(path.join(Directory.current.path, appName));

    if (!templateDir.existsSync()) {
      _logger.err('Template directory not found!');
      return;
    }

    // Create project directory
    try {
      await appDir.create(recursive: true);
    } catch (e) {
      _logger.err('Failed to create project directory: $e');
      _logger.info(
        'Please ensure you have write permissions in the current directory.',
      );
      return;
    }

    _logger.info('Creating project directory at: ${appDir.path}');

    // Define directories to be skipped (like /macos, /ios)
    final directoriesToSkip = ['macos', 'ios', 'windows', 'linux'];

    // Copy the template
    await for (final entity in templateDir.list(recursive: true)) {
      final relativePath = entity.path.replaceFirst(templateDir.path, '');

      // Skip directories that are in the skip list
      if (directoriesToSkip.any((dir) => relativePath.startsWith('/$dir'))) {
        _logger.detail('Skipping $relativePath');
        continue;
      }

      final targetPath = path.join(appDir.path, relativePath.substring(1));

      if (entity is File) {
        await File(entity.path).copy(targetPath);
      } else if (entity is Directory) {
        await Directory(targetPath).create(recursive: true);
      }
    }

    _logger.info('Project "$appName" created successfully from template.');

    // Update import statements in all Dart files
    await _updateImportStatements(appDir, appName, templatePackageName);
  }

  Future<void> _updateImportStatements(
    Directory appDir,
    String appName,
    String templateDirectoryName,
  ) async {
    final dartFiles = appDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in dartFiles) {
      var content = await file.readAsString();
      content = content.replaceAll(
        'package:$templateDirectoryName',
        'package:${appName.toLowerCase().replaceAll(' ', '_')}',
      );
      await file.writeAsString(content);
    }

    _logger.info('Import statements updated in all Dart files.');
  }
}
