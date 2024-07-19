import 'dart:async';
import 'dart:io';
import 'package:io/ansi.dart';
import 'package:package_config/package_config.dart';

import 'base/command.dart';
import 'package:path/path.dart' as p;

class RunCommand extends DyteCommand {
  @override
  final String name = "run";

  @override
  final String description = "Start a development server for your app";

  @override
  FutureOr? run() async {
    // get directory
    final cwd = Directory.current;
    final dir = (argResults?.rest ?? []).isEmpty ? "." : argResults!.rest[0];
    final projectDir = Directory(p.join(cwd.absolute.path, dir));
    if (!(await projectDir.exists())) {
      logger.error("The directory at ${projectDir.path} does not exist", error: true);
      exit(1);
    }
    
    final configPath = File(p.join(projectDir.path, "dyte.config.dart"));
    if (!(await configPath.exists())) {
      logger.error("The directory at ${projectDir.path} does not exist", error: true);
      exit(1);
    }

    // ensure package has been built and all dependencies installed
    final packageConfigPath = File(p.join(projectDir.path, ".dart_tool", "package_config.json"));

    if (!(await packageConfigPath.exists())) {
      logger.warn("Package config cannot be found");
      logger.info("Running 'dart pub get'");
      var success = (await dyteRunner.run("dart", args: ["pub", "get"], cwd: projectDir.path)) == 0;

      if (!success) {
        logger.error("Cannot resolve package. Run --verbose to see logging", error: true);
        exit(1);
      }
    }
    final packageConfig = await findPackageConfig(projectDir);

    // get configuration
    
  }
}