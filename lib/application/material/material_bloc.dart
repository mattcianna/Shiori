import 'dart:async';

import 'package:darq/darq.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shiori/domain/enums/enums.dart';
import 'package:shiori/domain/models/models.dart';
import 'package:shiori/domain/services/genshin_service.dart';
import 'package:shiori/domain/services/resources_service.dart';
import 'package:shiori/domain/services/telemetry_service.dart';

part 'material_bloc.freezed.dart';
part 'material_event.dart';
part 'material_state.dart';

class MaterialBloc extends Bloc<MaterialEvent, MaterialState> {
  final GenshinService _genshinService;
  final TelemetryService _telemetryService;
  final ResourceService _resourceService;

  MaterialBloc(this._genshinService, this._telemetryService, this._resourceService) : super(const MaterialState.loading());

  @override
  @override
  Stream<MaterialState> mapEventToState(MaterialEvent event) async* {
    final s = await event.map(
      loadFromKey: (e) async {
        final material = _genshinService.materials.getMaterial(e.key);
        if (e.addToQueue) {
          await _telemetryService.trackMaterialLoaded(e.key);
        }
        return _buildInitialState(material);
      },
    );

    yield s;
  }

  MaterialState _buildInitialState(MaterialFileModel material) {
    final translation = _genshinService.translations.getMaterialTranslation(material.key);
    final characters = _genshinService.characters.getCharacterForItemsUsingMaterial(material.key);
    final weapons = _genshinService.weapons.getWeaponForItemsUsingMaterial(material.key);
    final droppedBy = _genshinService.monsters.getRelatedMonsterToMaterialForItems(material.key);
    final obtainedFrom = material.obtainedFrom.where((el) => el.createsMaterialKey == material.key).map((el) {
      final needs = el.needs.map((e) {
        final img = _genshinService.materials.getMaterialImg(e.key);
        return ItemCommonWithQuantity(e.key, img, e.quantity);
      }).toList();
      return ItemObtainedFrom(el.createsMaterialKey, needs);
    }).toList();

    //TODO: SHOW THE QUANTITY IN THE RELATED MATERIALS
    final relatedMaterials = material.recipes
        .map((el) {
          final material = _genshinService.materials.getMaterial(el.createsMaterialKey);
          return ItemCommon(material.key, _resourceService.getMaterialImagePath(material.image, material.type));
        })
        .distinct((x) => x.key)
        .toList();
    return MaterialState.loaded(
      name: translation.name,
      fullImage: _resourceService.getMaterialImagePath(material.image, material.type),
      rarity: material.rarity,
      type: material.type,
      description: translation.description,
      characters: characters,
      weapons: weapons,
      days: material.days,
      obtainedFrom: obtainedFrom,
      relatedMaterials: relatedMaterials,
      droppedBy: droppedBy,
    );
  }
}
