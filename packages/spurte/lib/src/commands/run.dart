import 'dart:async';
import 'dart:io';

import 'package:io/ansi.dart';

import '../cli/shared.dart';
import '../config_file.dart';
import '../options/options.dart';
import '../plugin.dart';
import '../serve.dart';
import 'base/command.dart';

class RunCommand extends SpurteCommand {
  @override
  final String name = "run";

  @override
  final String description = "Start a development server for your app";

  RunCommand() {
    argParser..addFlag(
      'launch',
      abbr: 'l',
      negatable: false,
      defaultsTo: false,
      help: 'Launch app in browser once loaded (Chrome only supported)'
    )..addFlag(
      'repl',
      help: 'Whether to include a REPL for controlling the app from the command line',
      negatable: true,
      defaultsTo: true,
    )..addFlag(
      'log-requests',
      negatable: false,
      defaultsTo: false,
      help: "Log requests (verbose) to the standard output"
    )
    ;
  }

  @override
  FutureOr? run() async {
    final result = await preCommand(argResults?.rest ?? [], logger, spurteRunner);

    final config = result.config;
    final projectDir = result.cwd;

    // run plugins
    try {
      await runPlugins(config.plugins?.toList() ?? [], projectDir, config: getConfigFile(projectDir, "spurte"));
    } catch (e) {
      logger.error(e.toString(), error: true);
      exit(1);
    }

    // create server options from configuration
    final serverOptions = createServerOptions(config, projectDir.path);

    // build web server and run
    final server = await serve(serverOptions, log: argResults?['log-requests']);

    final serverDest = "http${config.server?.https == null ? "" : "s"}://${config.server?.host ?? "localhost"}:${config.server?.port ?? 8000}";

    final webServer = await server.listen(
      serverOptions.port, 
      onListen: () => print(blue.wrap("""${styleBold.wrap("SPURTE")}

Web Server Started!
- Local: ${yellow.wrap(serverDest)}
"""
))
    );

    if (argResults?['launch']) {

    }

    if (argResults?['repl']) server.repl(webServer.server);
  }
}
