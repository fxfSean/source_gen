
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen_example/service/service_annotations.dart';
import 'package:source_gen_example/src/utils.dart';

class ServiceUseCaseGenerator extends GeneratorForAnnotation<ServiceUseCase> {


  @override
  String? generateForAnnotatedElement(Element element,
      ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      final name = element.displayName;
      throw InvalidGenerationSourceError(
          'Generator cannot target `$name`.',
      todo: 'Remove the [ServiceUseCase] annotation from `$name`.',
      );
    }
    final className = element.name;
    final classBuilder = Class((c) {
      c
      ..name = _getClassName(className)
          ..methods.addAll(_parseMethods(element));
    });
    final emitter = DartEmitter();
    return DartFormatter().format('${classBuilder.accept(emitter)}');
    return '''
import 'package:get_it/get_it.dart';

import '../../smarthome_domain.dart';
import 'model.dart';
import 'repository.dart';

class DeviceTrafficUseCase {
  final DeviceTrafficRepository _repo = GetIt.I<DeviceTrafficRepository>();

  Future<AddOrderBody> addOrder(
      String iccid, String pk, String dn, String goodsId) async {
    return await _repo.addOrder(iccid, pk, dn, goodsId);
  }
}

''';
  }

  String _getClassName(String repoClassName) {
    if (!repoClassName.contains('Repository')) {
      throw InvalidGenerationSourceError(
          'Class name invalid `$repoClassName`.',
          todo: 'Should ends with [Repository].',);
    }
    var i = repoClassName.indexOf('Repository');
    return repoClassName.substring(0, i);
  }

  Iterable<Method> _parseMethods(ClassElement element) =>
      <MethodElement>[
        ...element.methods,
        ...element.mixins.expand((i) => i.methods)]
      .where((MethodElement m) => m.isAbstract &&
            (m.returnType.isDartAsyncFuture || m.returnType.isDartAsyncStream)
      ).map((m) => _generateMethod(m)!);

  Method? _generateMethod(MethodElement m) => Method((mm) {
      mm
        ..returns = refer(
            _displayString(m.type.returnType, withNullability: true))
        ..name = m.displayName
        ..types.addAll(m.typeParameters.map((e) => refer(e.name)))
        ..modifier = m.returnType.isDartAsyncFuture
            ? MethodModifier.async
            : MethodModifier.asyncStar;

      /// required parameters
      mm.requiredParameters.addAll(m.parameters
          .where((it) => it.isRequiredPositional)
          .map((it) => Parameter((p) => p
        ..name = it.name
        ..named = it.isNamed)));

      /// optional positional or named parameters
      mm.optionalParameters.addAll(
          m.parameters.where((i) => i.isOptional || i.isRequiredNamed).map(
              (it) => Parameter((p) => p
            ..required = (
                it.isNamed
                && it.type.nullabilitySuffix == NullabilitySuffix.none
                && !it.hasDefaultValue)
            ..name = it.name
            ..named = it.isNamed
            ..defaultTo = it.defaultValueCode == null
                ? null
                : Code(it.defaultValueCode!))));
    });

  String _displayString(dynamic e, {bool withNullability = false}) {
    try {
      return e.getDisplayString(withNullability: withNullability) as String;
    } catch (error) {
      if (error is TypeError) {
        return e.getDisplayString() as String;
      } else {
        rethrow;
      }
    }
  }

}


extension DartTypeStreamAnnotation on DartType {
  bool get isDartAsyncStream {
    final element = this.element == null ? null : this.element as ClassElement;
    if (element == null) {
      return false;
    }
    return element.name == "Stream" && element.library.isDartAsync;
  }
}