import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _Linter();

class _Linter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    _PreferConstEmptyLiterals(),
  ];
}

class _PreferConstEmptyLiterals extends DartLintRule {
  const _PreferConstEmptyLiterals()
    : super(
        code: const LintCode(
          name: 'prefer_const_empty_literals',
          problemMessage:
              'Use const for empty list/map/set literals to avoid allocations.',
          errorSeverity: ErrorSeverity.WARNING,
        ),
      );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addListLiteral((node) {
      if (node.elements.isEmpty && !node.isConst) {
        reporter.atNode(node, code);
      }
    });

    context.registry.addSetOrMapLiteral((node) {
      if (node.elements.isEmpty && !node.isConst) {
        reporter.atNode(node, code);
      }
    });
  }

  @override
  List<Fix> getFixes() => [_AddConstFix()];
}

class _AddConstFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    Diagnostic analysisError,
    List<Diagnostic> others,
  ) {
    context.registry.addListLiteral((node) {
      if (node.elements.isEmpty && !node.isConst) {
        reporter
            .createChangeBuilder(message: 'Add const keyword', priority: 50)
            .addDartFileEdit((builder) {
              builder.addInsertion(node.offset, (editBuilder) {
                editBuilder.write('const ');
              });
            });
      }
    });

    context.registry.addSetOrMapLiteral((node) {
      if (node.elements.isEmpty && !node.isConst) {
        reporter
            .createChangeBuilder(message: 'Add const keyword', priority: 50)
            .addDartFileEdit((builder) {
              builder.addInsertion(node.offset, (editBuilder) {
                editBuilder.write('const ');
              });
            });
      }
    });
  }
}
