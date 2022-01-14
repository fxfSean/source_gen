
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:source_gen_example/src/service_usecase_generator.dart';


Builder serviceBuilder(BuilderOptions options) =>
    LibraryBuilder(
        ServiceUseCaseGenerator(),
        generatedExtension: '.usecase.dart');